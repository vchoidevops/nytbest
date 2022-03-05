//
//  AsyncImageView.swift
//  NYBest
//
//  Created by victor.choi on 2/19/22.
//

import UIKit

enum AsyncImageViewError: Error {
    case imageLoadingError
}

class AsyncImageView: UIImageView {
    private var loader: UIActivityIndicatorView = UIActivityIndicatorView(style: .medium)
    var url: String? {
        didSet {
            guard let url = self.url else { return }
            Task.init(priority: .background) {
                try await self.load(url: url)
            }
        }
    }
    
    init(frame: CGRect, url: String?) {
        super.init(frame: frame)
        self.url = url
        self.loader.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(loader)
        NSLayoutConstraint.activate([
            loader.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            loader.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("not implemented")
    } 
}

extension AsyncImageView {
    private func load(url: String) async throws {
        DispatchQueue.main.async {
            self.loader.startAnimating()
        }
        do {
            let imageFromCache = try await ImageCache.publicCache.get(url: url as NSString)
            DispatchQueue.main.async {
                self.image = imageFromCache
                self.loader.stopAnimating()
            }
        } catch {
            self.loader.stopAnimating()
        }
    }
}
