//
//  BookView.swift
//  NYBest
//
//  Created by Woongshik Choi on 2/19/22.
//

import UIKit

class BookView: UIView, UIContentView {
    var imageView: AsyncImageView = AsyncImageView(frame: CGRect(x: 0, y: 0, width: 114.9, height: 173.57), url: nil)
    var configuration: UIContentConfiguration {
        didSet {
            self.configure(configuration: configuration)
        }
    }
    init(_ configuration: UIContentConfiguration) {
        self.configuration = configuration
        super.init(frame: .zero)
        self.frame = CGRect(x: 0, y: 0, width: 114.9, height: 173.57)
        
        self.imageView.layer.cornerRadius = CGFloat(10)
        self.addSubview(self.imageView)
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            imageView.topAnchor.constraint(equalTo: self.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            imageView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(configuration: UIContentConfiguration) {
        guard let config = configuration as? BookViewConfiguration else { return }
        self.imageView.url = config.imageURL
    }
}

struct BookViewConfiguration: UIContentConfiguration {
    var imageURL: String = ""
    func makeContentView() -> UIView & UIContentView {
        return BookView(self)
    }
    func updated(for state: UIConfigurationState) -> BookViewConfiguration {
        return self
    }
}
