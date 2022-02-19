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
    var url: String? {
        didSet {
            guard let url = self.url else { return }
            self.load(url: url)
        }
    }
    
    init(frame: CGRect, url: String?) {
        super.init(frame: frame)
        self.url = url
    }
    
    required init?(coder: NSCoder) {
        fatalError("not implemented")
    }
}

extension AsyncImageView {
    private func load(url: String) {
        if let imageFromCache = ImageCache().get(url: url as NSString) {
            DispatchQueue.main.async {
                self.image = imageFromCache
            }
            
        } else {
            URLSession.shared.dataTask(with: URL(string: url)!) { data, response, error in
                if error != nil {
                    print("Error to download image")
                    return
                }
                guard let data = data, let image = UIImage(data: data) else { return }
                ImageCache().add(image: image, url: url as NSString)
                DispatchQueue.main.async {
                    self.image = image
                }
            }.resume()
        }
    }
}
