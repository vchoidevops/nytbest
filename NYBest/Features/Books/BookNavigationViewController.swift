//
//  BookNavigationViewController.swift
//  NYBest
//
//  Created by Woongshik Choi on 2/20/22.
//

import UIKit

class BookNavigationViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        initNavigationController()
    }
    
    private func initNavigationController() {
        setViewControllers([BooksViewController()], animated: false)
    }
}
