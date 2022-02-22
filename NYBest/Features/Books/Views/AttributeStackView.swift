//
//  AttributeStackView.swift
//  NYBest
//
//  Created by victor.choi on 2/21/22.
//

import UIKit

class AttributeStackView: UIStackView {
    private lazy var titleLabel: UILabel = {
       let label = UILabel()
        label.textColor = .systemGray
        label.font = .systemFont(ofSize: 12)
        return label
    }()
    private var contentLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.numberOfLines = 0
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 12)
        return label
     }()
    
    init(_ title: String, _ content: String) {
        super.init(frame: CGRect(x: 0, y: 0, width: 60, height: 30))
        self.axis = .vertical
        self.distribution = .fill
        self.alignment = .top
        
        self.titleLabel.text = title
        self.contentLabel.text = content
        
        self.insertArrangedSubview(titleLabel, at: 0)
        self.insertArrangedSubview(contentLabel, at: 1)
        
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
