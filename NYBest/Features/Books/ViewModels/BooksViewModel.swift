//
//  BooksViewModel.swift
//  NYBest
//
//  Created by victor.choi on 2/12/22.
//

import Foundation
import Combine

final class BooksViewModel {
    var genres = CurrentValueSubject<[Genre]?, Error>(nil)
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
                switch error {
                case .failure(let error):
                    self.genres.send(completion: .failure(error))
                case .finished:
                    self.genres.send(completion: .finished)
                }
            }, receiveValue: { [weak self] data in
                guard let data = data, let self = self else { return }
                self.genres.send(data)
            })
            .store(in: &trashBag)

    }
    
    
}
