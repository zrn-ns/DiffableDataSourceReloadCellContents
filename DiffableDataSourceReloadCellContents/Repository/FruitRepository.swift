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
            var tmpFruits = _fruits
            tmpFruits.remove(at: index)
            tmpFruits.append(.init(id: fruit.id,
                                   name: fruit.name,
                                   isFavorite: !fruit.isFavorite))
            _fruits = tmpFruits
        }
    }
}
