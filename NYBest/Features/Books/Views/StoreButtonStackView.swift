//
//  StoreButtonStackView.swift
//  NYBest
//
//  Created by Woongshik Choi on 2/21/22.
//

import UIKit

protocol StoreButtonStackViewDelegate {
    func didTapButton(_ index: Int) -> Void
}
protocol StoreButtonStackViewType {
    var delegate: StoreButtonStackViewDelegate? { get set }
}

class StoreButtonStackView: UIStackView, StoreButtonStackViewType {
    var delegate: StoreButtonStackViewDelegate?
    private var appleBookStoreButton: UIButton = {
       let button = UIButton()
        button.setBackgroundImage(UIImage(named: "icon-apple-bookstore"), for: .normal)
        button.tag = 2
        button.addTarget(self, action: #selector(tapStoreButton(_:)), for: .touchUpInside)
        return button
    }()
    private var amazonBookStoreButton: UIButton = {
       let button = UIButton()
        button.setBackgroundImage(UIImage(named: "icon-amazon-store"), for: .normal)
        button.tag = 0
        button.addTarget(self, action: #selector(tapStoreButton(_:)), for: .touchUpInside)
        return button
    }()
    private var barnesNobleButton: UIButton = {
        let button = UIButton()
        button.tag = 1
        button.setBackgroundImage(UIImage(named: "icon-barnes_noble"), for: .normal)
        button.addTarget(self, action: #selector(tapStoreButton(_:)), for: .touchUpInside)
        
        return button
    }()
    
     @objc private func tapStoreButton(_ sender: UIButton) {
         delegate?.didTapButton(sender.tag)
    }
    
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        axis = .vertical
        distribution = .fill
        alignment = .leading
        spacing = 8
        
        self.insertArrangedSubview(amazonBookStoreButton, at: 0)
        self.insertArrangedSubview(barnesNobleButton, at: 1)
        self.insertArrangedSubview(appleBookStoreButton, at: 2)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
