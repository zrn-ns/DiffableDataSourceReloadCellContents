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

    private struct Item: Hashable {
        let fruitId: UUID
    }

    private struct Fruit {
        var name: String
        var isFavorite: Bool

        init(name: String, isFavorite: Bool) {
            self.name = name
            self.isFavorite = isFavorite
        }

        mutating func toggleFavorite() {
            isFavorite = !isFavorite
        }
    }

    private var fruits: [UUID: Fruit] = [.init(): .init(name: "Grape Fruits", isFavorite: false),
                                         .init(): .init(name: "Orange", isFavorite: false),
                                         .init(): .init(name: "Cabos", isFavorite: false),
                                         .init(): .init(name: "Citron", isFavorite: true),
                                         .init(): .init(name: "Lime", isFavorite: false),
                                         .init(): .init(name: "Bergamot", isFavorite: false),
                                         .init(): .init(name: "Iyokan Orange", isFavorite: false),
                                         .init(): .init(name: "Dekopon", isFavorite: false)] {
        didSet {
            updateDataSource()
        }
    }

    private var items: [Item] {
        fruits.sorted(by: { $0.value.name < $1.value.name })
            .map { Item(fruitId: $0.key) }
    }

    private lazy var collectionViewDataSource: UICollectionViewDiffableDataSource<Section, Item> = .init(collectionView: collectionView) { [weak self] (collectionView: UICollectionView, indexPath: IndexPath, item: Item) -> UICollectionViewCell? in
        guard let _self = self,
              let fruit = _self.fruits[item.fruitId] else { return nil }

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

    /// CollectionViewのデータソースを更新する
    private func updateDataSource() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.default])
        snapshot.appendItems(items)

        collectionViewDataSource.apply(snapshot, animatingDifferences: true)
    }

    // セルのインスタンスは更新せず、中身だけ更新する
    private func reloadContentsOfItem(item: Item) {
        guard let indexPath = collectionViewDataSource.indexPath(for: item),
              let cell = collectionView.cellForItem(at: indexPath) as? FruitCell,
              let fruit = fruits[item.fruitId] else { return }
        cell.viewModel = .init(name: fruit.name,
                               isFavorite: fruit.isFavorite)
    }
}

extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let itemTapped = collectionViewDataSource.itemIdentifier(for: indexPath) {
            fruits[itemTapped.fruitId]?.toggleFavorite()
            reloadContentsOfItem(item: itemTapped)
        }
    }
}
