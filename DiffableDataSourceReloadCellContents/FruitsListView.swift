//
//  FruitsListView.swift
//  DiffableDataSourceReloadCellContents
//
//  Created by zrn_ns on 2021/07/23.
//

import UIKit

class FruitsListView: UIView {

    var fruits: [FruitRepository.Fruit] = [] {
        didSet {
            updateDataSource()
        }
    }

    var didSelectFruitHandler: ((FruitRepository.Fruit) -> Void)?

    required init?(coder: NSCoder) {
        collectionView = UICollectionView.init(frame: .zero, collectionViewLayout: Self.createLayout())
        collectionView.register(.init(nibName: "FruitCell", bundle: nil), forCellWithReuseIdentifier: "FruitCell")

        super.init(coder: coder)

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(collectionView)
        self.addConstraints([
            collectionView.topAnchor.constraint(equalTo: self.topAnchor),
            collectionView.leftAnchor.constraint(equalTo: self.leftAnchor),
            collectionView.rightAnchor.constraint(equalTo: self.rightAnchor),
            collectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        ])

        collectionView.delegate = self
        collectionView.dataSource = collectionViewDataSource
        collectionView.backgroundColor = .white
    }

    private enum Section: Hashable {
        case `default`
    }

    private struct Item: Hashable {
        let fruitId: UUID
    }

    private var items: [Item] {
        fruits.sorted(by: { $0.name < $1.name })
            .map { Item(fruitId: $0.id) }
    }

    private var collectionView: UICollectionView

    /// CollectionViewのデータソースを更新する
    private func updateDataSource() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.default])
        snapshot.appendItems(items)

        collectionViewDataSource.apply(snapshot, animatingDifferences: true)

        self.items.forEach { self.reloadContentsOfItem(item: $0) }
    }

    private lazy var collectionViewDataSource: UICollectionViewDiffableDataSource<Section, Item> = .init(collectionView: collectionView) { [weak self] (collectionView: UICollectionView, indexPath: IndexPath, item: Item) -> UICollectionViewCell? in
        guard let fruit = self?.fruits.first(where: { $0.id == item.fruitId }) else { return nil }

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FruitCell", for: indexPath) as! FruitCell
        cell.viewModel = .init(name: fruit.name, isFavorite: fruit.isFavorite)
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

    // セルのインスタンスは更新せず、セルの中身だけ更新する
    private func reloadContentsOfItem(item: Item) {
        guard let indexPath = collectionViewDataSource.indexPath(for: item),
              let cell = collectionView.cellForItem(at: indexPath) as? FruitCell,
              let fruit = fruits.first(where: { $0.id == item.fruitId }) else { return }
        cell.viewModel = .init(name: fruit.name,
                               isFavorite: fruit.isFavorite)
    }
}

extension FruitsListView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let itemTapped = collectionViewDataSource.itemIdentifier(for: indexPath),
           let fruit = fruits.first(where: { $0.id == itemTapped.fruitId }) {

            didSelectFruitHandler?(fruit)
        }
    }
}
