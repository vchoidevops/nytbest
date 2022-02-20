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
    var listFilters = CurrentValueSubject<Set<Int>, Never>([])
    var trashBag = Set<AnyCancellable>()
    
    init() {
        getBestSellers()
        setupSearchTextBinding()
        setupListFilters()
        setupCombineListfilterAndSearchFilter()
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
        if searchText.isEmpty {
            return self.totalGenres
        }
        let result: [Genre]? = self.totalGenres.filter { genre in
            let books = genre.books.filter { book in
                return book.title.lowercased().contains(searchText.lowercased())
            }
            return books.count > 0
        }
        return result
    }
    
    private func filterWithSearchTextAndListFilters(_ listFilters: Set<Int>, _ searchText: String?) -> [Genre]? {
        if listFilters.isEmpty {
            return searchWithFilter(searchText ?? "")
        }
        let listFiltered = self.totalGenres.enumerated().filter { listFilters.contains($0.offset) }.map { $0.element }
        print("List Filtered \(listFiltered.count)")
        guard let searchText = searchText else { return listFiltered }
        
        return listFiltered.filter { genre in
            let books = genre.books.filter { book in
                return book.title.lowercased().contains(searchText.lowercased())
            }
            return books.count > 0
        }
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
                self.genres.send(genres)
            })
            .store(in: &trashBag)
    }
    
    private func filterWithListFilters(_ filters: Set<Int>) -> [Genre] {
        if filters.isEmpty {
            return self.totalGenres
        }
        return self.totalGenres.enumerated().filter { filters.contains($0.offset) }.map { $0.element }
    }
    
    private func setupListFilters() {
        listFilters.debounce(for: 0.5, scheduler: RunLoop.main, options: nil)
            .map { self.filterWithListFilters($0) }
            .eraseToAnyPublisher()
            .sink { completion in
                print("Completed: \(completion)")
            } receiveValue: { genres in
                print("List Filtered \(genres.count)")
                self.genres.send(genres)
            }
            .store(in: &trashBag)

    }
    
    private func setupCombineListfilterAndSearchFilter() {
        listFilters.combineLatest(searchText)
            .map { listfilters, searchText in
                return self.filterWithSearchTextAndListFilters(listfilters, searchText)
            }
            .compactMap { $0 }
            .eraseToAnyPublisher()
            .sink { completion in
                print("\(completion)")
            } receiveValue: { genres in
                self.genres.send(genres)
            }
            .store(in: &trashBag)

    }
}
