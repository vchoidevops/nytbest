//
//  ImageCache.swift
//  NYBest
//
//  Created by victor.choi on 2/19/22.
//

import Foundation
import UIKit

public class ImageCache {
    public static let publicCache = ImageCache()
    var placeholderImage = UIImage(systemName: "rectangle")
    private let cachedImages: NSCache<NSString, UIImage> = {
        let cache = NSCache<NSString, UIImage>()
        cache.countLimit = 100
        cache.totalCostLimit = 1024 * 1024 * 100
        return cache
    }()
    
    func add(image: UIImage, url: NSString) {
        self.cachedImages.setObject(image, forKey: url)
    }
    func get(url: NSString) -> UIImage? {
        guard let image = self.cachedImages.object(forKey: url) else { return nil }
        return image
    }
}
