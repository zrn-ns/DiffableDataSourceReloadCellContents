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
    }

    // MARK: - outlet

    @IBOutlet weak var listView: FruitsListView! {
        didSet {
            listView.didSelectFruitHandler = { [weak self] fruit in
                self?.repository.toggleFavorite(of: fruit)
            }
        }
    }

    // MARK: - private

    private let repository: FruitRepository = .init()
    private var cancellables: [AnyCancellable] = []

    private func setupSubscription() {
        repository.fruits.assign(to: \.fruits, on: listView)
            .store(in: &cancellables)
    }
}
