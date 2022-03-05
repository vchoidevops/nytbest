//
//  ImageCache.swift
//  NYBest
//
//  Created by victor.choi on 2/19/22.
//

import Foundation
import UIKit

public enum ImageCacheError: String, Error {
    case loadError = "failed to load an image"
}

public class ImageCache {
    public static let publicCache = ImageCache()
    var placeholderImage = UIImage(systemName: "rectangle")
    private let cachedImages: NSCache<NSString, UIImage> = {
        let cache = NSCache<NSString, UIImage>()
        cache.countLimit = 100
        cache.totalCostLimit = 1024 * 1024 * 100
        return cache
    }()
    
    public func add(image: UIImage, url: NSString) {
        self.cachedImages.setObject(image, forKey: url)
    }
    public func get(url: NSString) async throws -> UIImage {
        guard let image = self.cachedImages.object(forKey: url) else {
            let image = try await loadImage(for: url)
            self.add(image: image, url: url)
            return image
        }
        return image
    }
    private func loadImage(for url: NSString) async throws -> UIImage {
        let url: URL = URL(string: url as String)!
        return try await withCheckedThrowingContinuation({ (continuation: CheckedContinuation<UIImage, Error>) in
            DispatchQueue.global(qos: .background).async {
                guard let data = try? Data(contentsOf: url), let image = UIImage(data: data) else {
                    continuation.resume(throwing: ImageCacheError.loadError)
                    return
                }
                continuation.resume(returning: image)
            }
        })
    }
}
