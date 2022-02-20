//
//  GenreView.swift
//  NYBest
//
//  Created by victor.choi on 2/13/22.
//

import UIKit

class GenreView: UIView, UIContentView {
    var textLabel: UILabel = UILabel()
    var isSelected: Bool = false
    
    var configuration: UIContentConfiguration {
        didSet {
            self.configure(configuration: configuration)
        }
    }
    var newYorkFont: UIFont {
        let descriptor = UIFont.systemFont(ofSize: 12, weight: .semibold).fontDescriptor
        if let self = descriptor.withDesign(.serif) {
            return UIFont(descriptor: self, size: 0)
        }
        return UIFont(descriptor: descriptor, size: 0)
    }
    init(_ configuration: UIContentConfiguration) {
        self.configuration = configuration
        super.init(frame: .zero)
        self.frame = CGRect(x: 0, y: 0, width: 114.06, height: 73)
        self.textLabel.lineBreakMode = .byCharWrapping
        self.textLabel.numberOfLines = 0
        self.textLabel.font = newYorkFont.withSize(12)
        self.layer.borderWidth = 1.2
        self.layer.borderColor = CGColor(red: 42/255, green: 42/255, blue: 42/255, alpha: 1.0)
        self.layer.cornerRadius = CGFloat(7)
        self.textLabel.draw(CGRect(x: 5, y: 10, width: 104, height: 52))
        self.addSubview(textLabel)
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            textLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            textLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            textLabel.heightAnchor.constraint(equalToConstant: 52),
            textLabel.widthAnchor.constraint(equalToConstant: 104)
            ])
        self.configure(configuration: configuration)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(configuration: UIContentConfiguration) {
        guard let config = configuration as? GenreViewConfiguration else { return }
        
        self.textLabel.textColor = config.isSelected ? .white : .black
        self.backgroundColor = config.isSelected ? .black : .systemBackground
        let paragraphStyle = NSMutableParagraphStyle()
        
        paragraphStyle.lineBreakMode = .byWordWrapping
        
        textLabel.attributedText = NSAttributedString(string: config.text, attributes: [
            NSAttributedString.Key.paragraphStyle: paragraphStyle
        ])
    }
}

struct GenreViewConfiguration: UIContentConfiguration {
    var text: String = ""
    var isSelected: Bool = false
    
    func makeContentView() -> UIView & UIContentView {
        return GenreView(self)
    }
    
    func updated(for state: UIConfigurationState) -> GenreViewConfiguration {
        return self
    }
}
