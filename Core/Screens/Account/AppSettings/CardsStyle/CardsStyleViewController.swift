//
//  CardsStyleViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 03/05/2023.
//

import UIKit
import Combine

class CardsStyleViewController: UIViewController {

    // MARK: Private Properties
    private lazy var topView: UIView = Self.createTopView()
    private lazy var backButton: UIButton = Self.createBackButton()
    private lazy var topTitleLabel: UILabel = Self.createTopTitleLabel()
    private lazy var topStackView: UIStackView = Self.createTopStackView()

    // MARK: Public Properties
    var cancellables = Set<AnyCancellable>()
    var viewModel: CardsStyleViewModel

    // MARK: Lifetime and Cycle
    init() {
        var currentCardStyle = 1
        switch StyleHelper.cardsStyleActive() {
        case .small:
            currentCardStyle = 2
        case .normal:
            currentCardStyle = 1
        }

        self.viewModel = CardsStyleViewModel(currentCardStyleId: currentCardStyle)

        super.init(nibName: nil, bundle: nil)
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupSubviews()
        self.setupWithTheme()

        self.setupTopStackView()

        self.backButton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

    }

    // MARK: Layout and Theme
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    func setupWithTheme() {
        self.view.backgroundColor = UIColor.App.backgroundPrimary

        self.topView.backgroundColor = UIColor.App.backgroundPrimary

        self.backButton.tintColor = UIColor.App.textPrimary

        self.topTitleLabel.textColor = UIColor.App.textPrimary

        self.topStackView.backgroundColor = UIColor.App.backgroundSecondary

    }

    private func setupTopStackView() {
        let cardsStyleView = SettingsRowView()
        cardsStyleView.setTitle(title: localized("cards_style"))

        let normalCardView = SettingsRadioRowView()
        normalCardView.setTitle(title: localized("normal"))
        normalCardView.viewId = 1
        normalCardView.hasSeparatorLineView = true

        let smallCardView = SettingsRadioRowView()
        smallCardView.setTitle(title: localized("small"))
        smallCardView.viewId = 2

        let currentCardStyleActive = self.viewModel.currentCardStyleId

        if currentCardStyleActive == 1 {
            normalCardView.isChecked = true
        }
        else if currentCardStyleActive == 2 {
            smallCardView.isChecked = true
        }

        normalCardView.didTapView = { [weak self] _ in
            UserDefaults.standard.cardsStyle = .normal

            smallCardView.isChecked = false
            normalCardView.isChecked = true

            NotificationCenter.default.post(name: .cardsStyleChanged, object: nil)

        }

        smallCardView.didTapView = { [weak self] _ in
            UserDefaults.standard.cardsStyle = .small

            smallCardView.isChecked = true
            normalCardView.isChecked = false

            NotificationCenter.default.post(name: .cardsStyleChanged, object: nil)
        }

        self.topStackView.addArrangedSubview(cardsStyleView)
        self.topStackView.addArrangedSubview(normalCardView)
        self.topStackView.addArrangedSubview(smallCardView)

    }
}

//
// MARK: - Actions
//
extension CardsStyleViewController {
    @objc private func didTapBackButton() {
        self.navigationController?.popViewController(animated: true)
    }

}

//
// MARK: Subviews initialization and setup
//
extension CardsStyleViewController {

    private static func createTopView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createBackButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("", for: .normal)
        button.setImage(UIImage(named: "arrow_back_icon"), for: .normal)
        return button
    }

    private static func createTopTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("cards_style")
        label.font = AppFont.with(type: .bold, size: 17)
        label.textAlignment = .center
        return label
    }

    private static func createTopStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.layer.cornerRadius = CornerRadius.button
        return stackView
    }

    private func setupSubviews() {
        self.view.addSubview(self.topView)

        self.topView.addSubview(self.backButton)
        self.topView.addSubview(self.topTitleLabel)
        self.topView.bringSubviewToFront(self.topTitleLabel)

        self.view.addSubview(self.topStackView)

        self.initConstraints()
    }

    private func initConstraints() {

        // Top bar
        NSLayoutConstraint.activate([
            self.topView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.topView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.topView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.topView.heightAnchor.constraint(equalToConstant: 44),

            self.backButton.leadingAnchor.constraint(equalTo: self.topView.leadingAnchor, constant: 0),
            self.backButton.centerYAnchor.constraint(equalTo: self.topView.centerYAnchor),
            self.backButton.heightAnchor.constraint(equalToConstant: 44),
            self.backButton.widthAnchor.constraint(equalToConstant: 40),

            self.topTitleLabel.leadingAnchor.constraint(equalTo: self.topView.leadingAnchor, constant: 20),
            self.topTitleLabel.trailingAnchor.constraint(equalTo: self.topView.trailingAnchor, constant: -20),
            self.topTitleLabel.centerYAnchor.constraint(equalTo: self.topView.centerYAnchor)

        ])

        // Top StackView
        NSLayoutConstraint.activate([
            self.topStackView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            self.topStackView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
            self.topStackView.topAnchor.constraint(equalTo: self.topView.bottomAnchor, constant: 8),

        ])

    }

}
