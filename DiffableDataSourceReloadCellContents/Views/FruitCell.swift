//
//  FruitCell.swift
//  DiffableDataSourceReloadCellContents
//
//  Created by zrn_ns on 2021/07/23.
//

import UIKit

class FruitCell: UICollectionViewCell {

    struct ViewModel {
        var name: String
        var isFavorite: Bool
    }

    // NOTE: セルのインスタンスの同一性がわかるように色をつける
    let bgColor = UIColor(red: .random(in: 0.0..<1.0), green: .random(in: 0.0..<1.0), blue: .random(in: 0.0..<1.0), alpha: 0.5)

    var viewModel: ViewModel = .init(name: "", isFavorite: false) {
        didSet {
            updateView()
        }
    }

    func updateView() {
        UIView.animate(withDuration: 0.2) {
            self.nameLabel.text = self.viewModel.name
            self.favoriteIconImageView.alpha = self.viewModel.isFavorite ? 1 : 0
            self.backgroundColor = self.bgColor
        }

    }

    override func prepareForReuse() {
        super.prepareForReuse()

        viewModel = .init(name: "", isFavorite: false)
    }

    // MARK: - private

    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var favoriteIconImageView: UIImageView!
}
