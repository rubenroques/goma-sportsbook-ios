//
//  AppearanceViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 18/02/2022.
//

import UIKit
import Combine

class AppearanceViewController: UIViewController {

    // MARK: Private Properties
    private lazy var topView: UIView = Self.createTopView()
    private lazy var backButton: UIButton = Self.createBackButton()
    private lazy var topTitleLabel: UILabel = Self.createTopTitleLabel()
    private lazy var topStackView: UIStackView = Self.createTopStackView()
    private var cancellables = Set<AnyCancellable>()

    // MARK: Public Properties
    var themeRadioButtonViews: [SettingsRadioRowView] = []
    var viewModel: AppearanceViewModel

    // MARK: Lifetime and Cycle
    init() {
        self.viewModel = AppearanceViewModel()
        super.init(nibName: nil, bundle: nil)

        self.bind(toViewModel: self.viewModel)
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

    // MARK: Binding
    private func bind(toViewModel viewModel: AppearanceViewModel) {

        viewModel.selectedThemePublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { theme in
                if theme == Theme.dark {
                    UIApplication.shared.keyWindow?.overrideUserInterfaceStyle = .dark
                }
                else if theme == Theme.light {
                    UIApplication.shared.keyWindow?.overrideUserInterfaceStyle = .light
                }
                else if theme == Theme.device {
                    UIApplication.shared.keyWindow?.overrideUserInterfaceStyle = .unspecified
                }
            })
            .store(in: &cancellables)

    }

    private func setupTopStackView() {
        let themeColorView = SettingsRowView()
        themeColorView.setTitle(title: localized("theme_color"))

        let darkModeView = SettingsRadioRowView()
        darkModeView.setTitle(title: localized("dark_mode"))
        darkModeView.viewId = 1
        darkModeView.hasSeparatorLineView = true
        self.viewModel.themeRadioButtonViews.append(darkModeView)

        let lightModeView = SettingsRadioRowView()
        lightModeView.setTitle(title: localized("light_mode"))
        lightModeView.viewId = 2
        lightModeView.hasSeparatorLineView = true
        self.viewModel.themeRadioButtonViews.append(lightModeView)

        let syncModeView = SettingsRadioRowView()
        syncModeView.setTitle(title: localized("sync_with_system"))
        syncModeView.viewId = 3
        self.viewModel.themeRadioButtonViews.append(syncModeView)

        self.viewModel.setSelectedView()

        self.topStackView.addArrangedSubview(themeColorView)
        self.topStackView.addArrangedSubview(darkModeView)
        self.topStackView.addArrangedSubview(lightModeView)
        self.topStackView.addArrangedSubview(syncModeView)

    }

}

//
// MARK: - Actions
//
extension AppearanceViewController {
    @objc private func didTapBackButton() {
        self.navigationController?.popViewController(animated: true)
    }

}

//
// MARK: Subviews initialization and setup
//
extension AppearanceViewController {

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
        label.text = localized("appearance")
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

        // StackView
        NSLayoutConstraint.activate([
            self.topStackView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            self.topStackView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
            self.topStackView.topAnchor.constraint(equalTo: self.topView.bottomAnchor, constant: 8),

        ])

    }

}
