//
//  BooksViewController.swift
//  NYBest
//
//  Created by victor.choi on 2/12/22.
//

import UIKit
import Combine

class BooksViewController: UIViewController {
    lazy var viewModel: BooksViewModel = BooksViewModel()
    
    var collectionView: UICollectionView!
    var datasource: UICollectionViewDiffableDataSource<CompositeSection, AnyHashable>! = nil
    
    var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        self.setupSearchField()
        self.setupCollectionView()
        self.configDataSource()
        self.setupBindings()
        self.setupNavigationItem()
        
        // 1. Check Where a user taps
        setupTapRecognizer()
        
    }
    private func setupTapRecognizer() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleKeyboardNotification))
        view.addGestureRecognizer(tapRecognizer)
        tapRecognizer.delegate = self
    }
    
    @objc private func handleKeyboardNotification(gesture: UITapGestureRecognizer) {
        print("Notification ===> ")
        searchBar.endEditing(true)
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
    private func setupSearchField() {
        searchBar = UISearchBar()
        searchBar.backgroundColor = .systemBackground
        searchBar.searchBarStyle = .minimal
        searchBar.delegate = self
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(searchBar)
        
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            searchBar.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func setupBindings() {
        viewModel.genres
            .receive(on: RunLoop.main, options: nil)
            .sink { error in
                switch error {
                case .failure(let error):
                    print("ERROR:\(error)")
                case .finished:
                    print("FINISHED")
                }
            } receiveValue: { [weak self] results in
                guard let self = self else { return }
                self.configDataSource()
                self.collectionView.reloadData()
            }
            .store(in: &viewModel.trashBag)
    }
}

extension BooksViewController {
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) in
            let sectionConstant = sectionIndex == 0 ? SectionConstants.genreGroup : SectionConstants.bookGroup
            
            let columns = sectionConstant.columnCount
            let item = NSCollectionLayoutItem(layoutSize: sectionConstant.itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 6.94)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: sectionConstant.groupHeight)
            
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columns)
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 8
            section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
            section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 16, bottom: 20, trailing: 16)
            
            if sectionIndex != 0 {
                let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: sectionConstant.headerSize , elementKind: "Header", alignment: .topLeading)
                section.boundarySupplementaryItems = [header]
            }
            return section
        }
        return layout
    }
    private func setupCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    private func configDataSource() {
        let genreCellRegistration = UICollectionView.CellRegistration<UICollectionViewCell, Genre> { cell, indexPath, item in
            var genreConfig = GenreViewConfiguration()
            genreConfig.isSelected = self.viewModel.listFilters.value.contains(indexPath.row)
            genreConfig.text = "\(item.displayName)"
            cell.contentConfiguration = genreConfig
        }
        let bookCellRegistration = UICollectionView.CellRegistration<UICollectionViewCell, Book> { cell, indexPath, item in
            let bookConfig = BookViewConfiguration(imageURL: item.bookImage)
            cell.contentConfiguration = bookConfig
        }
        
        datasource = UICollectionViewDiffableDataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            if let item = itemIdentifier as? Genre {
                return collectionView.dequeueConfiguredReusableCell(using: genreCellRegistration, for: indexPath, item: item)
            } else if let item = itemIdentifier as? Book {
                return collectionView.dequeueConfiguredReusableCell(using: bookCellRegistration, for: indexPath, item: item)
            } else {
                fatalError()
            }
        })
        
        let headerRegistration = UICollectionView.SupplementaryRegistration
        <BookListHeaderView>(elementKind: "Header") {
            (supplementaryView, title, indexPath) in
            guard let values = self.viewModel.genres.value else { return }
            supplementaryView.label.text = "\(values[indexPath.section - 1].listName)"
            supplementaryView.backgroundColor = .clear
            supplementaryView.layer.borderColor = UIColor.black.cgColor
            supplementaryView.layer.borderWidth = 0
        }
        datasource.supplementaryViewProvider = {
            collectionView, kind, indexPath in
            if indexPath.section != 0 {
                return collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
            } else {
                return UICollectionReusableView()
            }
        }
        
        var snapshotList = NSDiffableDataSourceSnapshot<CompositeSection, AnyHashable>()
        
        guard let genres = viewModel.genres.value else { return }
        
        let layoutKind = CompositeSection(id: "genres")
        var sections: [CompositeSection] = [layoutKind]
        let layoutKinds = genres.map { CompositeSection(id: $0.listNameEncoded) }
        sections.append(contentsOf: layoutKinds)
        snapshotList.appendSections(sections)
        snapshotList.appendItems(viewModel.totalGenres, toSection: layoutKind)
        
        for genre in genres {
            snapshotList.appendItems(genre.books, toSection: CompositeSection(id: genre.listNameEncoded))
        }
        datasource.apply(snapshotList, animatingDifferences: false)
    }
}

extension BooksViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            
            guard let cell = collectionView.cellForItem(at: indexPath) else { fatalError() }
            
            var filters: Set<Int> = viewModel.listFilters.value
            if filters.contains(indexPath.row) {
                filters.remove(indexPath.row)
            } else {
                filters.insert(indexPath.row)
            }
            var genreConfig = cell.contentConfiguration as! GenreViewConfiguration
            genreConfig.isSelected = filters.contains(indexPath.row)
            cell.contentConfiguration = genreConfig
            
            viewModel.listFilters.send(filters)
        } else { // Select Book Cover
            guard let genres = viewModel.genres.value else { return }
            let vc = BookDetailViewController()
            let section = genres[indexPath.section - 1]
            let book = section.books[indexPath.row]
            vc.book = book
            vc.listName = section.listName
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension BooksViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.searchText.send(searchText)
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

extension BooksViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let eventClass = touch.view?.superview?.description, !eventClass.contains("UISearchBar") {
            print("EVENT CLASS: \(eventClass.contains("UISearchBar"))")
            searchBar.endEditing(true)
        }
        return false
    }
}
