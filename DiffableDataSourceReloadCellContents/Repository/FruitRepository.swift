//
//  FruitRepository.swift
//  DiffableDataSourceReloadCellContents
//
//  Created by zrn_ns on 2021/07/23.
//

import Combine
import Foundation

final class FruitRepository {

    class Fruit {
        let id: UUID
        var name: String
        var isFavorite: Bool

        init(id: UUID, name: String, isFavorite: Bool) {
            self.id = id
            self.name = name
            self.isFavorite = isFavorite
        }

        func toggleFavorite() {
            isFavorite = !isFavorite
        }
    }

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
        _fruits.first(where: { $0.id == fruit.id })?.toggleFavorite()
    }
}
