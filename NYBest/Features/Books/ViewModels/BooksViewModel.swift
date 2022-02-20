//
//  BooksViewModel.swift
//  NYBest
//
//  Created by victor.choi on 2/12/22.
//

import Foundation
import Combine

final class BooksViewModel {
    var genres = CurrentValueSubject<[Genre]?, Never>(nil)
    var totalGenres: [Genre] = []
    var searchText = PassthroughSubject<String?, Never>()
    var trashBag = Set<AnyCancellable>()
    
    init() {
        getBestSellers()
        setupSearchTextBinding()
    }
    
    private func getBestSellers() {
        let publisher: AnyPublisher<Bestsellers, Error> = NYTBooksAPI.books.runPublisher()
        
        publisher
            .map(\.results)
            .map(\.lists)
            .sink(receiveCompletion: { completion in
                print("Completion: \(completion)")
//                switch error {
//                case .failure(let error):
//                    self.genres.send(completion: .failure(error))
//                case .finished:
//                    self.genres.send(completion: .finished)
//                }
            }, receiveValue: { [weak self] data in
                guard let data = data, let self = self else { return }
                self.genres.send(data)
                self.totalGenres = data
            })
            .store(in: &trashBag)
    }
    
    private func searchWithFilter(_ searchText: String) -> [Genre]? {
        guard let genres = self.genres.value else { return nil }
        if searchText.isEmpty {
            return self.totalGenres
        }
        let result: [Genre]? = genres.filter { genre in
            let books = genre.books.filter { book in
                return book.title.lowercased().contains(searchText.lowercased())
            }
            return books.count > 0
        }
        return result
    }
    
    private func setupSearchTextBinding() {
        searchText.debounce(for: 0.5, scheduler: RunLoop.main, options: nil)
            .compactMap { $0 }
            .map { self.searchWithFilter($0) }
            .compactMap { $0 }
            .eraseToAnyPublisher()
            .sink(receiveCompletion: { error in
                switch error {
                case .failure(let error):
//                    self.genres.send(completion: .failure(error))
                    print("ERROR: \(error)")
                case .finished:
//                    self.genres.send(completion: .finished)
                    print("FINISHED: ")
                }
            }, receiveValue: { genres in
                print("Genres: \(genres.count)")
                self.genres.send(genres)
            })
            .store(in: &trashBag)
    }
}
