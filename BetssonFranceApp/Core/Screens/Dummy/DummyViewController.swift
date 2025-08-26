//
//  DummyViewController.swift
//  Sportsbook
//
//  Created by Ruben Roques on 05/06/2025.
//

import UIKit

class DummyViewController: UIViewController {

    // MARK: - Properties
    private let displayText: String
    private lazy var titleLabel: UILabel = Self.createTitleLabel()

    // MARK: - Initialization
    init(displayText: String) {
        self.displayText = displayText
        super.init(nibName: nil, bundle: nil)
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    // MARK: - Private Methods
    private func setupUI() {
        view.backgroundColor = UIColor.App.backgroundSecondary

        view.addSubview(titleLabel)
        titleLabel.text = displayText

        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -70),
            titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20)
        ])
    }
}

// MARK: - Factory Methods
private extension DummyViewController {

    static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = AppFont.with(type: .bold, size: 24)
        label.textColor = UIColor.App.textPrimary
        label.numberOfLines = 0
        return label
    }
}
