//
//  TipsControlViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 02/03/2023.
//

import UIKit

class TipsControlViewController: UIViewController {

    // MARK: Private Properties
    private lazy var topView: UIView = Self.createTopView()
    private lazy var backButton: UIButton = Self.createBackButton()
    private lazy var topTitleLabel: UILabel = Self.createTopTitleLabel()
    private lazy var scrollView: UIScrollView = Self.createScrollView()
    private lazy var scrollContainerView: UIView = Self.createScrollContainerView()
    private lazy var tipsStackView: UIStackView = Self.createTipsStackView()
    private lazy var tipButton: UIButton = Self.createTipButton()

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

        self.backButton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)

        self.tipButton.addTarget(self, action: #selector(didTapTipButton), for: .touchUpInside)

        self.setupStackView()

    }

    // MARK: Layout and Theme
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

//        self.tipButton.layer.cornerRadius = CornerRadius.button
//        self.tipButton.layer.borderWidth = 1
    }

    func setupWithTheme() {
        self.view.backgroundColor = UIColor.App.backgroundPrimary

        self.topView.backgroundColor = UIColor.App.backgroundPrimary

        self.backButton.backgroundColor = UIColor.App.backgroundPrimary
        self.backButton.setTitleColor(UIColor.App.textPrimary, for: .normal)
        self.backButton.setTitle("", for: .normal)
        self.backButton.tintColor = UIColor.App.textPrimary

        self.topTitleLabel.textColor = UIColor.App.textPrimary

        self.scrollView.backgroundColor = .clear

        self.scrollContainerView.backgroundColor = .clear

        self.tipsStackView.backgroundColor = .clear

        self.tipButton.backgroundColor = .clear
        // self.tipButton.layer.borderColor = UIColor(red: 0.16, green: 0.18, blue: 0.36, alpha: 1).cgColor
        self.tipButton.setTitleColor(UIColor.App.textPrimary, for: .normal)
    }

    // MARK: Functions
    private func setupStackView() {
        let textLabel = UILabel()
        // swiftlint:disable line_length
        textLabel.text = "Les conseils de Betsson pour garder le contrôle et faire du jeu une activité de loisir agréable et responsable. En suivant ces recommandations, vous pourrez éviter de vous mettre en difficulté financière ou émotionnelle.\n\nIl est important de se rappeler que le jeu doit être considéré comme un passe-temps, et non pas comme une source de revenus fiable. Fixer un budget raisonnable est un bon moyen de s'assurer que vous ne dépensez pas plus que vous ne pouvez-vous le permettre.\n\nConsultez régulièrement votre historique de jeu vous permettra de garder un œil sur vos dépenses et de détecter toute dérive éventuelle. Si vous commencez à ressentir des émotions négatives comme la frustration ou le stress, prenez une pause et faites autre chose pour vous détendre.\n\nEnfin, il est important de ne pas laisser le jeu prendre le pas sur vos responsabilités et obligations quotidiennes. Si vous sentez que le jeu commence à impacter négativement votre vie, n'hésitez pas à en parler à vos proches et à chercher de l'aide si nécessaire."
        textLabel.textColor = UIColor.App.textPrimary
        textLabel.font = AppFont.with(type: .bold, size: 16)
        textLabel.textAlignment = .left
        textLabel.numberOfLines = 0

        self.tipsStackView.addArrangedSubview(textLabel)
//        let tipView1 = TipInfoView()
//        tipView1.configure(title: localized("tip_title"), text: localized("tip_message"))
//
//        let tipView2 = TipInfoView()
//        tipView2.configure(title: localized("tip_title"), text: localized("tip_message"))
//
//        let tipView3 = TipInfoView()
//        tipView3.configure(title: localized("tip_title"), text: localized("tip_message"))
//
//        self.tipsStackView.addArrangedSubview(tipView1)
//        self.tipsStackView.addArrangedSubview(tipView2)
//        self.tipsStackView.addArrangedSubview(tipView3)

    }
}

//
// MARK: - Actions
//
extension TipsControlViewController {
    @objc private func didTapBackButton() {
        self.navigationController?.popViewController(animated: true)
    }

    @objc private func didTapTipButton() {
        if let url = URL(string: "https://www.evalujeu.fr/") {
            UIApplication.shared.open(url)
        }
    }
}

//
// MARK: Subviews initialization and setup
//
extension TipsControlViewController {

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
        button.contentMode = .scaleAspectFit
        return button
    }

    private static func createTopTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("tips_to_keep_control")
        label.font = AppFont.with(type: .bold, size: 20)
        label.textAlignment = .center
        return label
    }

    private static func createScrollView() -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }

    private static func createScrollContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createTipsStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.spacing = 25
        return stackView
    }

    private static func createTipButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        //button.setTitle(localized("evalujeu"), for: .normal)
        button.setImage(UIImage(named: "evalujeu_logo"), for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 2, left: 4, bottom: 2, right: 4)
        button.contentMode = .scaleAspectFit
        return button
    }

    private func setupSubviews() {
        self.view.addSubview(self.topView)

        self.topView.addSubview(self.backButton)
        self.topView.addSubview(self.topTitleLabel)

        self.view.addSubview(self.scrollView)

        self.scrollView.addSubview(self.scrollContainerView)

        self.scrollContainerView.addSubview(self.tipsStackView)
        self.scrollContainerView.addSubview(self.tipButton)

        self.initConstraints()
    }

    private func initConstraints() {

        // Top bar
        NSLayoutConstraint.activate([
            self.topView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.topView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.topView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.topView.heightAnchor.constraint(equalToConstant: 44),

            self.backButton.leadingAnchor.constraint(equalTo: self.topView.leadingAnchor),
            self.backButton.centerYAnchor.constraint(equalTo: self.topView.centerYAnchor),
            self.backButton.heightAnchor.constraint(equalToConstant: 44),
            self.backButton.widthAnchor.constraint(equalToConstant: 40),

            self.topTitleLabel.leadingAnchor.constraint(equalTo: self.topView.leadingAnchor, constant: 40),
            self.topTitleLabel.trailingAnchor.constraint(equalTo: self.topView.trailingAnchor, constant: -40),
            self.topTitleLabel.centerYAnchor.constraint(equalTo: self.topView.centerYAnchor),

        ])

        // Scroll view
        NSLayoutConstraint.activate([

            self.scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.scrollView.topAnchor.constraint(equalTo: self.topView.bottomAnchor),
            self.scrollView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),

            self.scrollContainerView.leadingAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.leadingAnchor),
            self.scrollContainerView.trailingAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.trailingAnchor),
            self.scrollContainerView.topAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.topAnchor),
            self.scrollContainerView.bottomAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.bottomAnchor),
            self.scrollContainerView.widthAnchor.constraint(equalTo: self.scrollView.frameLayoutGuide.widthAnchor)

        ])

        // Stack view
        NSLayoutConstraint.activate([
            self.tipsStackView.leadingAnchor.constraint(equalTo: self.scrollContainerView.leadingAnchor, constant: 20),
            self.tipsStackView.trailingAnchor.constraint(equalTo: self.scrollContainerView.trailingAnchor, constant: -20),
            self.tipsStackView.topAnchor.constraint(equalTo: self.scrollContainerView.topAnchor, constant: 20),

            self.tipButton.widthAnchor.constraint(equalToConstant: 205),
            self.tipButton.heightAnchor.constraint(equalToConstant: 50),
            self.tipButton.centerXAnchor.constraint(equalTo: self.scrollContainerView.centerXAnchor),
            self.tipButton.topAnchor.constraint(equalTo: self.tipsStackView.bottomAnchor, constant: 70),
            self.tipButton.bottomAnchor.constraint(equalTo: self.scrollContainerView.bottomAnchor, constant: -20)
        ])

    }

}
