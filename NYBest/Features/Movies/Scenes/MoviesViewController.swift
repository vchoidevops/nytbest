//
//  ViewController.swift
//  NYBest
//
//  Created by victor.choi on 2/12/22.
//

import UIKit

class MoviesViewController: UIViewController {
    
    private var label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .yellow
        
        setupViews()
        print("VIEW DID LOAD")
    }

    private func setupViews() {
        label = UILabel()
        label.text = "Movies"
        
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

}

