//
//  ViewController.swift
//  DiffableDataSourceReloadCellContents
//
//  Created by zrn_ns on 2021/07/23.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        updateDataSource()
    }

    // MARK: - outlet

    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.delegate = self
            collectionView.dataSource = collectionViewDataSource
            collectionView.collectionViewLayout = Self.createLayout()
            collectionView.register(.init(nibName: "FruitCell", bundle: nil), forCellWithReuseIdentifier: "FruitCell")
        }
    }

    // MARK: - private

    private enum Section: Hashable {
        case `default`
    }

    private struct FruitItem: Hashable {
        let id: UUID
        var name: String
        var isFavorite: Bool
    }

    private var fruits: [FruitItem] = [.init(id: UUID(), name: "Grape Fruits", isFavorite: false),
                                       .init(id: UUID(), name: "Orange", isFavorite: false),
                                       .init(id: UUID(), name: "Cabos", isFavorite: false),
                                       .init(id: UUID(), name: "Citron", isFavorite: true),
                                       .init(id: UUID(), name: "Lime", isFavorite: false),
                                       .init(id: UUID(), name: "Bergamot", isFavorite: false),
                                       .init(id: UUID(), name: "Iyokan Orange", isFavorite: false),
                                       .init(id: UUID(), name: "Dekopon", isFavorite: false)] {
        didSet {
            updateDataSource()
        }
    }

    private lazy var collectionViewDataSource: UICollectionViewDiffableDataSource<Section, FruitItem> = .init(collectionView: collectionView) { (collectionView: UICollectionView, indexPath: IndexPath, item: FruitItem) -> UICollectionViewCell? in
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FruitCell", for: indexPath) as! FruitCell
        cell.viewModel = .init(name: item.name, isFavorite: item.isFavorite)
        return cell
    }

    /// CollectionViewのLayoutを作成する
    private static func createLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                  heightDimension: .estimated(50))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: itemSize, subitems: [item])
            let section = NSCollectionLayoutSection(group: group)
            return section
        }
    }

    /// CollectionViewのデータソースを更新する
    private func updateDataSource() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, FruitItem>()
        snapshot.appendSections([.default])
        snapshot.appendItems(fruits)

        collectionViewDataSource.apply(snapshot, animatingDifferences: true)
    }

}

extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var fruitTapped = fruits[indexPath.row]
        fruitTapped.isFavorite = !fruitTapped.isFavorite
        fruits[indexPath.row] = fruitTapped
    }
}
