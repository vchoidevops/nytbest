//
//  NYBestRootViewController.swift
//  NYBest
//
//  Created by victor.choi on 2/12/22.
//

import UIKit

class NYBestRootViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabItems()
    }
    
    private func setupTabItems() {
        viewControllers = [MoviesViewController(), BooksViewController()]
        guard let vcs = viewControllers else { return }
        selectedViewController = vcs[0]
        
        vcs[0].tabBarItem = UITabBarItem(title: "Movies", image: UIImage(systemName: "play.rectangle.on.rectangle.fill"), tag: 0)
        vcs[1].tabBarItem = UITabBarItem(title: "Books", image: UIImage(systemName: "books.vertical.fill") , tag: 1)
    }

}
