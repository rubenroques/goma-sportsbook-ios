//
//  PromotionalHeaderViewController.swift
//  Demo
//
//  Created by André Lascas on 23/06/2025.
//

import Foundation
import UIKit
import GomaUI

class PromotionalHeaderViewController: UIViewController {
    private let promotionalHeaderView: PromotionalHeaderView
    private let viewModel: PromotionalHeaderViewModelProtocol

    init() {
        self.viewModel = MockPromotionalHeaderViewModel.defaultMock
        self.promotionalHeaderView = PromotionalHeaderView(viewModel: viewModel)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupPromotionalHeaderView()
    }

    private func setupPromotionalHeaderView() {
        promotionalHeaderView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(promotionalHeaderView)
        NSLayoutConstraint.activate([
            promotionalHeaderView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            promotionalHeaderView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            promotionalHeaderView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
}
