//
//  CapsuleViewController.swift
//  Demo
//
//  Created by Ruben Roques Code on 08/07/2025.
//

import Foundation
import UIKit
import GomaUI

class CapsuleViewController: UIViewController {
    private let capsuleViewModels: [(title: String, viewModel: MockCapsuleViewModel)] = [
        ("Live Badge", MockCapsuleViewModel.liveBadge),
        ("Count Badge", MockCapsuleViewModel.countBadge),
        ("Tag Style", MockCapsuleViewModel.tagStyle),
        ("Status Pending", MockCapsuleViewModel.statusPending),
        ("Status Success", MockCapsuleViewModel.statusSuccess),
        ("Status Error", MockCapsuleViewModel.statusError),
        ("Promotional New", MockCapsuleViewModel.promotionalNew),
        ("Promotional Hot", MockCapsuleViewModel.promotionalHot),
        ("Match Status Live", MockCapsuleViewModel.matchStatusLive),
        ("Match Status Half Time", MockCapsuleViewModel.matchStatusHalfTime),
        ("Market Count", MockCapsuleViewModel.marketCount),
        ("Custom Blue", MockCapsuleViewModel.custom(text: "Custom", backgroundColor: .systemBlue, textColor: .white)),
        ("Custom Large", MockCapsuleViewModel.custom(text: "Large Text", fontSize: 14, fontWeight: .bold, horizontalPadding: 16.0, verticalPadding: 8.0))
    ]
    private var capsuleViews: [CapsuleView] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGray6
        setupCapsuleViews()
    }

    private func setupCapsuleViews() {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 24
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false

        for (title, viewModel) in capsuleViewModels {
            let label = UILabel()
            label.text = title
            label.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
            label.textColor = .secondaryLabel
            label.textAlignment = .left
            label.numberOfLines = 1

            let capsuleView = CapsuleView(viewModel: viewModel)
            capsuleView.translatesAutoresizingMaskIntoConstraints = false
            capsuleViews.append(capsuleView)

            // Create a horizontal container to center the capsule view
            let capsuleContainer = UIView()
            capsuleContainer.translatesAutoresizingMaskIntoConstraints = false
            capsuleContainer.addSubview(capsuleView)
            
            NSLayoutConstraint.activate([
                capsuleView.leadingAnchor.constraint(greaterThanOrEqualTo: capsuleContainer.leadingAnchor),
                capsuleView.trailingAnchor.constraint(lessThanOrEqualTo: capsuleContainer.trailingAnchor),
                capsuleView.centerXAnchor.constraint(equalTo: capsuleContainer.centerXAnchor),
                capsuleView.topAnchor.constraint(equalTo: capsuleContainer.topAnchor),
                capsuleView.bottomAnchor.constraint(equalTo: capsuleContainer.bottomAnchor),
                capsuleContainer.heightAnchor.constraint(greaterThanOrEqualToConstant: 32)
            ])

            let container = UIStackView(arrangedSubviews: [label, capsuleContainer])
            container.axis = .vertical
            container.spacing = 8
            container.alignment = .fill
            container.distribution = .fill

            stackView.addArrangedSubview(container)
        }

        scrollView.addSubview(stackView)
        view.addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 40),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 32),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -32),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -40),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -64)
        ])
    }
}
