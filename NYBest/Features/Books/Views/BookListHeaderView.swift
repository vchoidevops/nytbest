//
//  BookListHeaderView.swift
//  NYBest
//
//  Created by victor.choi on 2/19/22.
//

import UIKit

class BookListHeaderView: UICollectionReusableView {
    let label = UILabel()
    var text: String = "" {
        didSet {
            DispatchQueue.main.async {
                self.label.text = self.text
            }
        }
    }
    static let reuseIdentifier = "book-list-header-view"

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        self.layer.borderColor = UIColor.clear.cgColor
        self.layer.borderWidth = 0
        
        configure()
    }
    required init?(coder: NSCoder) {
        fatalError()
    }
}

extension BookListHeaderView {
    func configure() {
        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor),
            label.trailingAnchor.constraint(equalTo: trailingAnchor),
            label.topAnchor.constraint(equalTo: topAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        
    }
}
