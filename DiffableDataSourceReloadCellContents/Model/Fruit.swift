//
//  Fruit.swift
//  DiffableDataSourceReloadCellContents
//
//  Created by zrn_ns on 2021/07/23.
//

import Foundation

struct Fruit: Equatable {
    let id: UUID
    var name: String
    var isFavorite: Bool

    init(id: UUID, name: String, isFavorite: Bool) {
        self.id = id
        self.name = name
        self.isFavorite = isFavorite
    }

    mutating func toggleFavorite() {
        isFavorite = !isFavorite
    }
}
