//
//  QuickLinksTabBarView.swift
//  GomaUI
//
//  Created by Ruben Roques on 19/05/2025.
//

import UIKit
import Combine
import SwiftUI

final public class QuickLinksTabBarView: UIView {
    // MARK: - Private Properties
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 2
        return stackView
    }()

    private let viewModel: QuickLinksTabBarViewModelProtocol
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Public Properties
    public var onQuickLinkSelected: ((QuickLinkType) -> Void) = { _ in }

    // MARK: - Initialization
    public init(viewModel: QuickLinksTabBarViewModelProtocol) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        self.setupSubviews()
        self.setupBindings()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func updateTheme() {
        self.backgroundColor = StyleProvider.Color.backgroundSecondary
    }

    // MARK: - Private Methods
    private func setupSubviews() {
        self.translatesAutoresizingMaskIntoConstraints = false

        self.updateTheme()

        self.addSubview(self.stackView)

        NSLayoutConstraint.activate([
            self.stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            self.stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            self.stackView.topAnchor.constraint(equalTo: topAnchor, constant: 2),
            self.stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -2),

            // Fixed height of 40 points
            self.heightAnchor.constraint(equalToConstant: 40.0)
        ])
    }

    private func setupBindings() {
        self.viewModel.quickLinksPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] quickLinks in
                self?.render(quickLinks: quickLinks)
            }
            .store(in: &cancellables)
    }

    private func render(quickLinks: [QuickLinkItem]) {
        // Clear existing quick links
        self.stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        // Add new quick links
        for item in quickLinks {
            let itemView = QuickLinkTabBarItemView()
            itemView.configure(with: item)

            itemView.onTap = { [weak self] in
                guard let self = self else { return }
                self.viewModel.didTapQuickLink(type: item.type)
                self.onQuickLinkSelected(item.type)
            }

            self.stackView.addArrangedSubview(itemView)
        }
    }
}

#if DEBUG
import SwiftUI

@available(iOS 17.0, *)
#Preview("Gaming Quick Links") {
    PreviewUIView {
        let mockViewModel = MockQuickLinksTabBarViewModel.gamingMockViewModel
        return QuickLinksTabBarView(viewModel: mockViewModel)
    }
    .frame(height: 40)
}

@available(iOS 17.0, *)
#Preview("Sports Quick Links") {
    PreviewUIView {
        let mockViewModel = MockQuickLinksTabBarViewModel.sportsMockViewModel
        return QuickLinksTabBarView(viewModel: mockViewModel)
    }
    .frame(height: 40)
}

@available(iOS 17.0, *)
#Preview("Account Quick Links") {
    PreviewUIView {
        let mockViewModel = MockQuickLinksTabBarViewModel.accountMockViewModel
        return QuickLinksTabBarView(viewModel: mockViewModel)
    }
    .frame(height: 40)
}
#endif
