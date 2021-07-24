//
//  FruitRepository.swift
//  DiffableDataSourceReloadCellContents
//
//  Created by zrn_ns on 2021/07/23.
//

import Combine
import Foundation

final class FruitRepository {

    lazy var fruits: AnyPublisher<[Fruit], Never> = $_fruits.eraseToAnyPublisher()

    @Published private var _fruits: [Fruit] = [.init(id: .init(), name: "Grape Fruits", isFavorite: false),
                                               .init(id: .init(), name: "Orange", isFavorite: false),
                                               .init(id: .init(), name: "Cabos", isFavorite: false),
                                               .init(id: .init(), name: "Citron", isFavorite: true),
                                               .init(id: .init(), name: "Lime", isFavorite: false),
                                               .init(id: .init(), name: "Bergamot", isFavorite: false),
                                               .init(id: .init(), name: "Iyokan Orange", isFavorite: false),
                                               .init(id: .init(), name: "Dekopon", isFavorite: false)]

    func toggleFavorite(of fruit: Fruit) {
        if let index = _fruits.firstIndex(of: fruit) {
            let updatedFruit: Fruit = {
                var tmpFruit = fruit
                tmpFruit.toggleFavorite()
                return tmpFruit
            }()
            var tmpFruits = _fruits
            tmpFruits.remove(at: index)
            tmpFruits.append(updatedFruit)
            _fruits = tmpFruits
        }
    }

    init() {
        // 一定時間おきにフルーツを追加する
        Timer.publish(every: 5, on: .main, in: .default)
            .autoconnect()
            .sink { [weak self] _ in
                guard let _self = self else { return }
                _self._fruits.append(.init(id: UUID(), name: "Other Fruit \(_self._fruits.count)", isFavorite: false))
            }.store(in: &cancellables)
    }

    // MARK: - private

    private var cancellables: [AnyCancellable] = []
}
