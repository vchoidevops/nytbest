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
    var searchText = CurrentValueSubject<String, Never>("")
    var listFilters = CurrentValueSubject<Set<Int>, Never>([])
    var trashBag = Set<AnyCancellable>()
    
    init() {
        getBestSellers()
        setupCombineListfilterAndSearchFilter()
    }
    
    private func getBestSellers() {
        let publisher: AnyPublisher<Bestsellers, Error> = NYTBooksAPI.books.runPublisher()
        
        publisher
            .map(\.results)
            .map(\.lists)
            .sink(receiveCompletion: { completion in
                print("Completion: \(completion)")
            }, receiveValue: { [weak self] data in
                guard let data = data, let self = self else { return }
                self.genres.send(data)
                self.totalGenres = data
            })
            .store(in: &trashBag)
    }
    
    private func searchWithText(_ searchText: String) -> [Genre]? {
        if searchText.isEmpty {
            return self.totalGenres
        }
        let result: [Genre]? = self.totalGenres.filter { genre in
            let books = genre.books.filter { book in
                return book.title.lowercased().contains(searchText.lowercased()) || book.bookDescription.lowercased().contains(searchText.lowercased())
            }
            return books.count > 0
        }.map { genre in
            var g = genre
            let filteredBooks = genre.books.filter { book in
                return book.title.lowercased().contains(searchText.lowercased()) || book.bookDescription.lowercased().contains(searchText.lowercased())
            }
            g.books = filteredBooks
            return g
        }
        return result
    }
    
    private func filterWithSearchTextAndListFilters(_ listFilters: Set<Int>, _ searchText: String) -> [Genre]? {
        if listFilters.isEmpty {
            return searchWithText(searchText)
        }
        let listFiltered = self.totalGenres.enumerated().filter { listFilters.contains($0.offset) }.map { $0.element }
        
        if searchText.isEmpty {
            return listFiltered
        } else {
            return listFiltered.filter { genre in
                let books = genre.books.filter { book in
                    return book.title.lowercased().contains(searchText.lowercased()) || book.bookDescription.lowercased().contains(searchText.lowercased())
                }
                return books.count > 0
            }.map { genre in
                var g = genre
                let filteredBooks = genre.books.filter { book in
                    return book.title.lowercased().contains(searchText.lowercased()) || book.bookDescription.lowercased().contains(searchText.lowercased())
                }
                g.books = filteredBooks
                return g
            }
        }
    }
    
    private func setupCombineListfilterAndSearchFilter() {
        Publishers.CombineLatest(searchText, listFilters)
            .map { self.filterWithSearchTextAndListFilters($1, $0) }
            .compactMap { $0 }
            .eraseToAnyPublisher()
            .sink { completion in
                print("\(completion)")
            } receiveValue: { [unowned self] genres in
                self.genres.send(genres)
            }
            .store(in: &trashBag)

    }
}
