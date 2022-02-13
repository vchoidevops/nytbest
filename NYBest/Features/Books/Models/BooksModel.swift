//
//  BooksModel.swift
//  NYBest
//
//  Created by victor.choi on 2/12/22.
//

import Foundation

// MARK: - Bestsellers
struct Bestsellers: Codable {
    let status, copyright: String
    let numResults: Int
    let results: BestSellerResults

    enum CodingKeys: String, CodingKey {
        case status, copyright
        case numResults = "num_results"
        case results
    }
}

// MARK: - BestSellerResults
struct BestSellerResults: Codable {
    let nextPublishedDate, bestsellersDate, publishedDate, publishedDateDescription, previousPublishedDate: String?
    let lists: [BookList]?

    enum CodingKeys: String, CodingKey {
        case bestsellersDate = "bestsellers_date"
        case publishedDate = "published_date"
        case publishedDateDescription = "published_date_description"
        case previousPublishedDate = "previous_published_date"
        case nextPublishedDate = "next_published_date"
        case lists
    }
}

// MARK: - List
struct BookList: Codable, Identifiable, Hashable {
    static func == (lhs: BookList, rhs: BookList) -> Bool {
        return lhs.id == rhs.id
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    let id: Int
    let listName, listNameEncoded, displayName: String
    let updated: Updated
    let listImage, listImageWidth, listImageHeight: String?
    let books: [Book]

    enum CodingKeys: String, CodingKey {
        case id = "list_id"
        case listName = "list_name"
        case listNameEncoded = "list_name_encoded"
        case displayName = "display_name"
        case updated
        case listImage = "list_image"
        case listImageWidth = "list_image_width"
        case listImageHeight = "list_image_height"
        case books
    }
}

// MARK: - Book
struct Book: Codable, Hashable, Equatable {
    static func == (lhs: Book, rhs: Book) -> Bool {
        return lhs.primaryIsbn10 == rhs.primaryIsbn10
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(primaryIsbn10)
    }
    let ageGroup: String
    let amazonProductURL: String
    let articleChapterLink, author: String
    let bookImage: String
    let bookImageWidth, bookImageHeight: Int
    let bookReviewLink: String
    let contributor, contributorNote, createdDate, bookDescription: String
    let firstChapterLink, price, primaryIsbn10, primaryIsbn13: String
    let bookURI, publisher: String
    let rank, rankLastWeek: Int
    let sundayReviewLink: String
    let title, updatedDate: String
    let weeksOnList: Int
    let buyLinks: [BuyLink]

    enum CodingKeys: String, CodingKey {
        case ageGroup = "age_group"
        case amazonProductURL = "amazon_product_url"
        case articleChapterLink = "article_chapter_link"
        case author
        case bookImage = "book_image"
        case bookImageWidth = "book_image_width"
        case bookImageHeight = "book_image_height"
        case bookReviewLink = "book_review_link"
        case contributor
        case contributorNote = "contributor_note"
        case createdDate = "created_date"
        case bookDescription = "description"
        case firstChapterLink = "first_chapter_link"
        case price
        case primaryIsbn10 = "primary_isbn10"
        case primaryIsbn13 = "primary_isbn13"
        case bookURI = "book_uri"
        case publisher, rank
        case rankLastWeek = "rank_last_week"
        case sundayReviewLink = "sunday_review_link"
        case title
        case updatedDate = "updated_date"
        case weeksOnList = "weeks_on_list"
        case buyLinks = "buy_links"
    }
}

// MARK: - BuyLink
struct BuyLink: Codable {
    let name: Name
    let url: String
}

enum Name: String, Codable {
    case amazon = "Amazon"
    case appleBooks = "Apple Books"
    case barnesAndNoble = "Barnes and Noble"
    case booksAMillion = "Books-A-Million"
    case bookshop = "Bookshop"
    case indieBound = "IndieBound"
}

enum Updated: String, Codable {
    case monthly = "MONTHLY"
    case weekly = "WEEKLY"
}
