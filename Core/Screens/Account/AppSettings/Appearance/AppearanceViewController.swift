//
//  AppearanceViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 18/02/2022.
//

import UIKit

class AppearanceViewController: UIViewController {

    // MARK: Private Properties
    private lazy var topView: UIView = Self.createTopView()
    private lazy var backButton: UIButton = Self.createBackButton()
    private lazy var topTitleLabel: UILabel = Self.createTopTitleLabel()
    private lazy var topStackView: UIStackView = Self.createTopStackView()

    // MARK: Public Properties
    var themeRadioButtonViews: [SettingsRadioRowView] = []

    // MARK: Lifetime and Cycle
    init() {
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
        let themeColorView = SettingsRowView()
        themeColorView.setTitle(title: localized("theme_color"))

        let darkModeView = SettingsRadioRowView()
        darkModeView.setTitle(title: localized("dark_mode"))
        darkModeView.viewId = 1
        darkModeView.hasSeparatorLineView = true
        self.themeRadioButtonViews.append(darkModeView)

        let lightModeView = SettingsRadioRowView()
        lightModeView.setTitle(title: localized("light_mode"))
        lightModeView.viewId = 2
        lightModeView.hasSeparatorLineView = true
        self.themeRadioButtonViews.append(lightModeView)

        let syncModeView = SettingsRadioRowView()
        syncModeView.setTitle(title: localized("sync_mode"))
        syncModeView.viewId = 3
        self.themeRadioButtonViews.append(syncModeView)

        // Set selected view
        let themeChosenId = UserDefaults.standard.theme.themeId
        
        for view in self.themeRadioButtonViews {
            view.didTapView = { _ in
                self.checkThemeRadioOptionsSelected( viewTapped: view)
            }
            // Default market selected
            if view.viewId == themeChosenId {
                view.isChecked = true
            }
        }

        self.topStackView.addArrangedSubview(themeColorView)
        self.topStackView.addArrangedSubview(darkModeView)
        self.topStackView.addArrangedSubview(lightModeView)
        self.topStackView.addArrangedSubview(syncModeView)

    }

    private func checkThemeRadioOptionsSelected(viewTapped: SettingsRadioRowView) {
        for view in self.themeRadioButtonViews {
            view.isChecked = false
        }
        viewTapped.isChecked = true

        if viewTapped.viewId == 1 {
            UserDefaults.standard.theme = Theme.dark
            UIApplication.shared.keyWindow?.overrideUserInterfaceStyle = .dark
        }
        else if viewTapped.viewId == 2 {
            UserDefaults.standard.theme = Theme.light
            UIApplication.shared.keyWindow?.overrideUserInterfaceStyle = .light
        }
        else if viewTapped.viewId == 3 {
            UserDefaults.standard.theme = Theme.device
            UIApplication.shared.keyWindow?.overrideUserInterfaceStyle = .unspecified

        }

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
        label.text = localized("notifications")
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
            self.topView.heightAnchor.constraint(equalToConstant: 70),

            self.backButton.leadingAnchor.constraint(equalTo: self.topView.leadingAnchor, constant: 10),
            self.backButton.centerYAnchor.constraint(equalTo: self.topView.centerYAnchor),
            self.backButton.heightAnchor.constraint(equalToConstant: 20),
            self.backButton.widthAnchor.constraint(equalToConstant: 15),

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
