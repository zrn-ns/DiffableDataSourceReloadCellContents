//
//  ViewController.swift
//  DiffableDataSourceReloadCellContents
//
//  Created by zrn_ns on 2021/07/23.
//

import Combine
import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        setupSubscription()
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

    private var items: [Item] {
        fruits.sorted(by: { $0.name < $1.name })
            .map { Item(fruitId: $0.id) }
    }

    private let repository: FruitRepository = .init()
    private var cancellables: [AnyCancellable] = []
    @Published private var fruits: [FruitRepository.Fruit] = []

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

    /// CollectionViewのデータソースを更新する
    private func updateDataSource() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.default])
        snapshot.appendItems(items)

        collectionViewDataSource.apply(snapshot, animatingDifferences: true)
    }

    // セルのインスタンスは更新せず、セルの中身だけ更新する
    private func reloadContentsOfItem(item: Item) {
        guard let indexPath = collectionViewDataSource.indexPath(for: item),
              let cell = collectionView.cellForItem(at: indexPath) as? FruitCell,
              let fruit = fruits.first(where: { $0.id == item.fruitId }) else { return }
        cell.viewModel = .init(name: fruit.name,
                               isFavorite: fruit.isFavorite)
    }

    private func setupSubscription() {
        repository.fruits.sink { [weak self] fruits in
            self?.updateDataSource()
        }.store(in: &cancellables)

        repository.fruits.assign(to: \.fruits, on: self)
            .store(in: &cancellables)
    }
}

extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let itemTapped = collectionViewDataSource.itemIdentifier(for: indexPath),
           let fruit = fruits.first(where: { $0.id == itemTapped.fruitId }) {

            repository.toggleFavorite(of: fruit)
            reloadContentsOfItem(item: itemTapped)
        }
    }
}
