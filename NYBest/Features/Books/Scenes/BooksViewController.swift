//
//  BooksViewController.swift
//  NYBest
//
//  Created by victor.choi on 2/12/22.
//

import UIKit

class BooksViewController: UIViewController {
    var viewModel: BooksViewModel?
    
    var collectionView: UICollectionView!
    var datasource: UICollectionViewDiffableDataSource<CompositeSection, AnyHashable>! = nil
    
    override func viewWillAppear(_ animated: Bool) {
        viewModel = BooksViewModel()
        self.setupBindings(viewModel!)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .blue
        self.setupCollectionView()
        self.configDataSource()
//        self.setupBindings()
    }
    
    private func setupBindings(_ viewModel: BooksViewModel) {
        viewModel.genres
            .receive(on: RunLoop.main, options: nil)
            .sink { error in
                print("TEST ===== \(error)")
            } receiveValue: { [weak self] results in
                guard let self = self, let results = results else { return }
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
            return section
        }
        return layout
    }
    private func setupCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
//        collectionView.dataSource = self
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    private func configDataSource() {
        let genreCellRegistration = UICollectionView.CellRegistration<UICollectionViewCell, Genre> { cell, indexPath, item in
            var genreConfig = GenreViewConfiguration()
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
        
        var snapshotList = NSDiffableDataSourceSnapshot<CompositeSection, AnyHashable>()
        
        guard let viewModel = viewModel, let genres = viewModel.genres.value else { return }
        
        let layoutKind = CompositeSection(id: "genres")
        var sections: [CompositeSection] = [layoutKind]
        let layoutKinds = genres.map { CompositeSection(id: $0.listNameEncoded) }
        sections.append(contentsOf: layoutKinds)
        snapshotList.appendSections(sections)
        snapshotList.appendItems(genres, toSection: layoutKind)
        for genre in genres {
            snapshotList.appendItems(genre.books, toSection: CompositeSection(id: genre.listNameEncoded))
        }
        datasource.apply(snapshotList, animatingDifferences: false)
    }
}
extension BooksViewController: UICollectionViewDelegate {
    
}
