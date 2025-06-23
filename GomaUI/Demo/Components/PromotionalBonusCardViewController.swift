//
//  PromotionalBonusCardViewController.swift
//  Demo
//
//  Created by André Lascas on 23/06/2025.
//

import Foundation
import UIKit
import GomaUI

class PromotionalBonusCardViewController: UIViewController {
    private let promotionalBonusCardView: PromotionalBonusCardView
    private let viewModel: PromotionalBonusCardViewModelProtocol

    init() {
        self.viewModel = MockPromotionalBonusCardViewModel.defaultMock
        self.promotionalBonusCardView = PromotionalBonusCardView(viewModel: viewModel)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupPromotionalBonusCardView()
    }

    private func setupPromotionalBonusCardView() {
        promotionalBonusCardView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(promotionalBonusCardView)
        NSLayoutConstraint.activate([
            promotionalBonusCardView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            promotionalBonusCardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            promotionalBonusCardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
}
