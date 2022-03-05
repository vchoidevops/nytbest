//
//  NYTAPI.swift
//  NYBest
//
//  Created by victor.choi on 2/12/22.
//

import Foundation
import Combine

fileprivate enum NYTBooksAPIConstants: String {
    case scheme = "https"
    case host = "api.nytimes.com"
    case path = "/svc/books/v3"
    case token = "A7c7lUtXoOAHe5LGQoLPjRP0nTVQLdW1"
}

enum NYTAPIErrors: Error {
    case decodingError
    case requestError
}

protocol NYTAPI {
    var url: URL? { get }
    var queryItems: [URLQueryItem]? { get }
    var endpoint: String { get }
    var method: String { get }
    var headers: [String: String]? { get }
    var request: URLRequest { get }
    func run<T: Codable>() async throws -> T
    func runPublisher<T>() -> AnyPublisher<T, Error> where T: Codable
}

enum NYTBooksAPI {
    case books
}

extension NYTBooksAPI: NYTAPI {
    func run<T: Codable>() async throws -> T {
        do {
            let (data, _) = try await URLSession.shared.data(for: self.request, delegate: nil)
            do {
                let decoded = try JSONDecoder().decode(T.self, from: data)
                return decoded
            } catch {
                throw NYTAPIErrors.decodingError
            }
        } catch {
            throw NYTAPIErrors.requestError
        }
    }
    func runPublisher<T>() -> AnyPublisher<T, Error> where T: Codable {
        return URLSession.shared.dataTaskPublisher(for: self.request)
            .subscribe(on: DispatchQueue.global(qos: .background))
            .tryMap { (data, response) in
                guard let response = response as? HTTPURLResponse, response.statusCode >= 200 && response.statusCode < 300 else { throw NYTAPIErrors.requestError }
                return data
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    var queryItems: [URLQueryItem]? {
        switch self {
        default:
            return [URLQueryItem(name: "api-key", value: NYTBooksAPIConstants.token.rawValue)]
        }
    }
    
    var method: String {
        switch self {
        default:
            return "GET"
        }
    }
    
    var headers: [String : String]? {
        switch self {
        default:
            return nil
        }
    }
    
    var request: URLRequest {
        switch self {
        case .books:
            var urlRequest: URLRequest = URLRequest(url: self.url!, timeoutInterval: Double.infinity)
            urlRequest.httpMethod = self.method
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            return urlRequest
        }
    }
    
    var endpoint: String {
        switch self {
        case .books:
            return "lists/overview.json"
        }
    }
    var url: URL? {
        var comps = URLComponents(string: NYTBooksAPIConstants.path.rawValue)
        comps?.scheme = NYTBooksAPIConstants.scheme.rawValue
        comps?.host = NYTBooksAPIConstants.host.rawValue
        
        switch self {
        case .books:
            comps?.path = "\(NYTBooksAPIConstants.path.rawValue)/\(self.endpoint)"
            comps?.queryItems = self.queryItems
            return comps?.url
        }
    }
}

