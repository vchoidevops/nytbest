//
//  BooksViewModel.swift
//  NYBest
//
//  Created by victor.choi on 2/12/22.
//

import Foundation
import Combine

final class BooksViewModel {
    var booklist = CurrentValueSubject<[BookList]?, Error>(nil)
    var trashBag = Set<AnyCancellable>()
    
    init() {
        getBestSellers()
    }
    
    private func getBestSellers() {
        let publisher: AnyPublisher<Bestsellers, Error> = NYTBooksAPI.books.runPublisher()
        
        publisher
            .map(\.results)
            .map(\.lists)
            .sink(receiveCompletion: { error in
                print("ERROR: \(error)")
                switch error {
                case .failure(let error):
                    self.booklist.send(completion: .failure(error))
                case .finished:
                    self.booklist.send(completion: .finished)
                }
            }, receiveValue: { data in
                guard let data = data else { return }
                self.booklist.send(data)
            })
            .store(in: &trashBag)

    }
    
    
}
