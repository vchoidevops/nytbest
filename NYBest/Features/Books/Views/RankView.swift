//
//  RankView.swift
//  NYBest
//
//  Created by Woongshik Choi on 2/21/22.
//

import UIKit

class RankView: UIView {
    private var titleLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 60, height: 20))
        label.text = "Rank"
        label.textColor = .systemGray
        label.font = .systemFont(ofSize: 12)
        return label
    }()
    private var starView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        return view
    }()
    private var imageView: UIImageView = {
       let imageView = UIImageView(image: UIImage(named: "star"))
       return imageView
    }()
    private var rankLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: 24, weight: .semibold)
        return label
    }()
    var rank: String = "" {
        didSet {
            DispatchQueue.main.async {
                self.rankLabel.text = self.rank
            }
        }
    }
    
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 60, height: 80))
    }
    
    override func layoutSubviews() {
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
            titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
        starView.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        rankLabel.translatesAutoresizingMaskIntoConstraints = false

        starView.addSubview(imageView)
        starView.addSubview(rankLabel)


        self.addSubview(starView)
        
        NSLayoutConstraint.activate([
            starView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            starView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            starView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 32)
        ])

        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: starView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: starView.centerYAnchor),
            rankLabel.centerXAnchor.constraint(equalTo: starView.centerXAnchor),
            rankLabel.centerYAnchor.constraint(equalTo: starView.centerYAnchor)
        ])
        
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
