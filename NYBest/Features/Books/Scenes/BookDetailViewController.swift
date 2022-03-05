//
//  BookDetailViewController.swift
//  NYBest
//
//  Created by victor.choi on 2/21/22.
//

import UIKit
import SafariServices

class BookDetailViewController: UIViewController {
    var book: Book!
    var listName: String!
    private var topContainer: UIStackView = {
       let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 8
        stack.alignment = .top
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private var topRightContainer: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fillProportionally
        stack.alignment = .leading
        stack.spacing = 5
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private var descriptionStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fillProportionally
        stack.alignment = .leading
        stack.spacing = 5
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private var storeStack: UIStackView = {
       let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fillProportionally
        stack.alignment = .leading
        stack.spacing = 5
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private var bookCoverView: UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 159.03, height: 242))
    
    fileprivate lazy var rankView: RankView = {
        let rankView = RankView()
        rankView.rank = "\(book.rank)"
        return rankView
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        Task {
            bookCoverView.image = nil
            bookCoverView.image = try await downloadImage(url: book.bookImage)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupDefaultView()
        setupNavigationItem()
        setupTopContainer()
        setupRightContent()
        setupDescriptionContent()
        setupStoreBuyButtons()
    }

    
    private func setupDefaultView() {
        self.view.backgroundColor = .systemBackground
    }
    
    private func setupTopContainer() {
        topContainer.addArrangedSubview(bookCoverView)
        self.view.addSubview(topContainer)
        
        NSLayoutConstraint.activate([
            topContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 5),
            topContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            topContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            topContainer.heightAnchor.constraint(equalToConstant: 270)
        ])
    }
    
    private func setupRightContent() {
        
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 60))
        titleLabel.text = book.title
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.numberOfLines = 0
        titleLabel.font = UIFont.newYorkFont.withSize(16)
        
        let authorStack = AttributeStackView("Author", book.author)
        let genreStack = AttributeStackView("Genre", listName)
        
        topRightContainer.insertArrangedSubview(titleLabel, at: 0)
        topRightContainer.insertArrangedSubview(authorStack, at: 1)
        topRightContainer.insertArrangedSubview(genreStack, at: 2)
        topRightContainer.insertArrangedSubview(rankView, at: 3)
        
        topContainer.addArrangedSubview(topRightContainer)
        
    }
    
    private func setupDescriptionContent() {
        if book.bookDescription.count > 0 {
            let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
            titleLabel.text = "Description"
            titleLabel.numberOfLines = 0
            titleLabel.font = .systemFont(ofSize: 24, weight: .semibold)
            
            descriptionStack.insertArrangedSubview(titleLabel, at: 0)
            
            let descriptionLabel = UILabel()
            descriptionLabel.text = book.bookDescription
            descriptionLabel.numberOfLines = 0
            descriptionLabel.font = .systemFont(ofSize: 14, weight: .regular)
            
            descriptionStack.insertArrangedSubview(descriptionLabel, at: 1)
            view.addSubview(descriptionStack)
            NSLayoutConstraint.activate([
                descriptionStack.topAnchor.constraint(equalTo: topContainer.bottomAnchor, constant: 20),
                descriptionStack.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
                descriptionStack.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16)
            ])
        }
    }
    
    private func setupStoreBuyButtons() {
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        titleLabel.text = "Where to buy"
        titleLabel.numberOfLines = 0
        titleLabel.font = .systemFont(ofSize: 24, weight: .semibold)
        
        storeStack.insertArrangedSubview(titleLabel, at: 0)
        let storeButtons = StoreButtonStackView()
        storeButtons.delegate = self
        storeStack.insertArrangedSubview(storeButtons, at: 1)
        
        view.addSubview(storeStack)
        if book.bookDescription.count > 0 {
            storeStack.topAnchor.constraint(equalTo: descriptionStack.bottomAnchor, constant: 20).isActive = true
        } else {
            storeStack.topAnchor.constraint(equalTo: topContainer.bottomAnchor, constant: 20).isActive = true
        }
        NSLayoutConstraint.activate([
            storeStack.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
            storeStack.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16)
        ])
    }
    
    private func setupNavigationItem() {
        let label = UILabel()
        guard let descriptor = UIFont.systemFont(ofSize: 24, weight: .semibold).fontDescriptor.withDesign(.serif) else { return }
        let font = UIFont(descriptor: descriptor, size: 18)
        label.text = "NY Bests"
        label.font = font
        
        self.navigationItem.titleView = label
        self.navigationItem.largeTitleDisplayMode = .always
    }
    
    private func downloadImage(url: String) async throws -> UIImage {
        let url = URL(string: url)!
        let (data, _) = try await URLSession.shared.data(from: url, delegate: nil)
        guard let image = UIImage(data: data) else { fatalError() }
        return image
    }
    
    private func findBuylink(_ index: Int) -> URL {
        switch index {
        case 0:
            return URL(string: book.buyLinks.filter { $0.name == .amazon }[0].url)!
        case 1:
            return URL(string: book.buyLinks.filter { $0.name == .barnesAndNoble }[0].url)!
        default:
            return URL(string: book.buyLinks.filter { $0.name == .appleBooks }[0].url)!
        }
    }
}

extension BookDetailViewController: StoreButtonStackViewDelegate {
    func didTapButton(_ index: Int) {
        let webView = SFSafariViewController(url: findBuylink(index))
        self.navigationController?.present(webView, animated: true, completion: nil)
    }
}
