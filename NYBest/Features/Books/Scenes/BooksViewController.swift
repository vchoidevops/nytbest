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
    var datasource: UICollectionViewDiffableDataSource<SectionLayoutKind, [BookList]>! = nil
    
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
        viewModel.booklist
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

enum SectionLayoutKind: Int, CaseIterable {
    case genres
    case booksByGenre
    static func getLayoutKind(_ sectionIndex: Int) -> SectionLayoutKind {
        if sectionIndex == 0 {
            return .genres
        } else {
            return .booksByGenre
        }
    }
    var columnCount: Int {
        switch self {
        case .booksByGenre:
            return 3
        default:
            return 3
        }
    }
    var itemSize: NSCollectionLayoutSize {
        switch self {
        case .genres:
            return NSCollectionLayoutSize(widthDimension: .absolute(114.06), heightDimension: .absolute(73))
        default:
            return NSCollectionLayoutSize(widthDimension: .absolute(204.57), heightDimension: .absolute(173.57))
        }
    }
    var groupHeight: NSCollectionLayoutDimension {
        switch self {
        case .genres:
            return .absolute(73)
        default:
            return .absolute(204.57)
        }
    }
}

extension BooksViewController {
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) in
            let sectionLayoutKind = SectionLayoutKind.getLayoutKind(sectionIndex)
            
            let columns = sectionLayoutKind.columnCount
            let item = NSCollectionLayoutItem(layoutSize: sectionLayoutKind.itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 6.94)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: sectionLayoutKind.groupHeight)
            
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
        let genreCellRegistration = UICollectionView.CellRegistration<UICollectionViewCell, [BookList]> { cell, indexPath, items in
            var genreConfig = GenreViewConfiguration()
            genreConfig.text = "\(items[indexPath.row].listName)"
            cell.contentConfiguration = genreConfig
        }
        let bookCellRegistration = UICollectionView.CellRegistration<UICollectionViewCell, [Book]> { cell, indexPath, items in
            cell.contentView.backgroundColor = .blue
            cell.contentView.layer.borderColor = UIColor.black.cgColor
            cell.contentView.layer.borderWidth = 1.2
            cell.contentView.layer.cornerRadius = SectionLayoutKind.getLayoutKind(indexPath.section) == .genres ? 0 : 8
        }
        
        datasource = UICollectionViewDiffableDataSource<SectionLayoutKind, [BookList]>(collectionView: collectionView) { (collectionView: UICollectionView, indexPath: IndexPath, items: [BookList]) -> UICollectionViewCell? in
            print("Index Path: ", indexPath.section)
            return SectionLayoutKind.getLayoutKind(indexPath.section) == .genres ? collectionView.dequeueConfiguredReusableCell(using: genreCellRegistration, for: indexPath, item: items)
            : collectionView.dequeueConfiguredReusableCell(using: bookCellRegistration, for: indexPath, item: items[indexPath.section].books)
        }
        
//        let itemPerSection = 10
        var snapshotList = NSDiffableDataSourceSnapshot<SectionLayoutKind, [BookList]>()
//        var snapshotBooks = NSDiffableDataSourceSnapshot<SectionLayoutKind, [[Book]]>()
        
        guard let viewModel = viewModel, let booklist = viewModel.booklist.value else { return }
        
        for idx in 0..<1 {
            let layoutKind = SectionLayoutKind.getLayoutKind(idx)
            snapshotList.appendSections([layoutKind])
            snapshotList.appendItems([booklist], toSection: .genres)
//            snapshotBooks.appendSections(<#T##identifiers: [SectionLayoutKind]##[SectionLayoutKind]#>)
        }
        
        datasource.apply(snapshotList, animatingDifferences: false)
    }
}
extension BooksViewController: UICollectionViewDelegate {
    
}
