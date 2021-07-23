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
        let fruitInfo: FruitInfo

        init(id: UUID, name: String, isFavorite: Bool) {
            self.id = id
            self.fruitInfo = .init(name: name, isFavorite: isFavorite)
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }

        public static func ==(lhs: FruitItem, rhs: FruitItem) -> Bool {
            lhs.id == rhs.id
                && lhs.fruitInfo === rhs.fruitInfo
        }

        class FruitInfo {
            var name: String
            var isFavorite: Bool

            init(name: String, isFavorite: Bool) {
                self.name = name
                self.isFavorite = isFavorite
            }
        }
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
        cell.viewModel = .init(name: item.fruitInfo.name, isFavorite: item.fruitInfo.isFavorite)
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

    // セルのインスタンスは更新せず、中身だけ更新する
    private func reloadContentsOfItem(item: FruitItem) {
        guard let indexPath = collectionViewDataSource.indexPath(for: item),
              let cell = collectionView.cellForItem(at: indexPath) as? FruitCell else { return }
        cell.viewModel = .init(name: item.fruitInfo.name,
                               isFavorite: item.fruitInfo.isFavorite)
    }
}

extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let fruitTapped = fruits[indexPath.row]
        fruits.filter({ $0 == fruitTapped }).forEach { $0.fruitInfo.isFavorite = !$0.fruitInfo.isFavorite }
        reloadContentsOfItem(item: fruitTapped)
    }
}
