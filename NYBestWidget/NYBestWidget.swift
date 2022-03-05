//
//  NYBestWidget.swift
//  NYBestWidget
//
//  Created by Woongshik Choi on 2/26/22.
//

import WidgetKit
import SwiftUI
import Intents

struct BestSellerProvider: IntentTimelineProvider {
    typealias Entry = BookEntry
    typealias Intent = GenreIntent
    
    func placeholder(in context: Context) -> BookEntry {
        .placeholder
    }

    func getSnapshot(for configuration: Intent, in context: Context, completion: @escaping (BookEntry) -> ()) {
        if context.isPreview {
            completion(.placeholder)
        }
        
        Task {
            do {
                let result: Bestsellers = try await NYTBooksAPI.books.run()
                guard let genres = result.results.lists else { return }
                let image = try await ImageCache.publicCache.get(url: genres[0].books[0].bookImage as NSString)
                let entry = BookEntry(date: Date(), configuration: configuration, bookTitle: genres[0].books[0].title, bookImage: image)
                completion(entry)
            } catch {
                completion(.placeholder)
            }
        }
    }

    func getTimeline(for configuration: Intent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let currentDate = Date()
        let entryDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!
        
        Task {
            do {
                let result: Bestsellers = try await NYTBooksAPI.books.run()
                guard let genres = result.results.lists else { return }
                let selected = getSelectedGenre(for: configuration.genre, list: genres)
                let image = try await ImageCache.publicCache.get(url: selected.books[0].bookImage as NSString)
                
                let entry = BookEntry(date: entryDate, configuration: configuration, bookTitle: selected.books[0].title, bookImage: image)
                
                let timeline = Timeline(entries: [entry], policy: .atEnd)
                completion(timeline)
            } catch {
                let timeline = Timeline(entries: [BookEntry.placeholder], policy: .atEnd)
                completion(timeline)
            }
        }
    }
    private func getSelectedGenre(for genre: BookGenre?, list genres: [Genre]) -> Genre {
        if let genre = genre, let listId = genre.identifier {
            return genres.filter { $0.listNameEncoded == listId }[0]
        } else {
            return genres[0]
        }
    }
}

struct BookEntry: TimelineEntry {
    let date: Date
    let configuration: GenreIntent
    let bookTitle: String
    let bookImage: UIImage
    
    static var placeholder: BookEntry {
        BookEntry(date: Date(), configuration: GenreIntent(), bookTitle: "THE PARIS APARTMENT", bookImage: UIImage(named: "sample_cover")!)
    }
}

struct NYBestWidgetEntryView : View {
    var entry: BestSellerProvider.Entry
    var body: some View {
        VStack {
            Image(uiImage: entry.bookImage)
                .resizable()
                .frame(minWidth: 80, idealWidth: 80, maxWidth: 80, minHeight: 125, idealHeight: 125, maxHeight: 125, alignment: .center)
            Text(entry.bookTitle)
                .font(.caption)
        }
    }
}

@main
struct NYBestWidget: Widget {
    let kind: String = "NYBestWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: GenreIntent.self, provider: BestSellerProvider()) { entry in
            NYBestWidgetEntryView(entry: entry)
        }
        .supportedFamilies([.systemSmall])
        .configurationDisplayName("Bestsellers")
        .description("Select a genre to see the top seller")
    }
}

struct NYBestWidget_Previews: PreviewProvider {
    static var previews: some View {
        NYBestWidgetEntryView(entry: BookEntry(date: Date(), configuration: GenreIntent(), bookTitle: "Test", bookImage: UIImage(systemName: "rectangle")!))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
