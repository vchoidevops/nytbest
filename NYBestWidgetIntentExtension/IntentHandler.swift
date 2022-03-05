//
//  IntentHandler.swift
//  NYBestWidgetIntentExtension
//
//  Created by Woongshik Choi on 3/4/22.
//

import Intents

enum IntentHandlerError: String, Error {
    case fetchingError = "Couldn't get the genres from the remote server"
}

class IntentHandler: INExtension, GenreIntentHandling {
    func provideGenreOptionsCollection(for intent: GenreIntent, with completion: @escaping (INObjectCollection<BookGenre>?, Error?) -> Void) {
        Task {
            do {
                let result: Bestsellers = try await NYTBooksAPI.books.run()
                guard let genres = result.results.lists else { return }
                let bookGenres = genres.map { BookGenre(identifier: $0.listNameEncoded, display: $0.displayName) }
                completion(INObjectCollection(items: bookGenres), nil)
            } catch {
                print("ERROR: \(error)")
                completion(INObjectCollection(items: []), error)
            }
        }
    }
}
