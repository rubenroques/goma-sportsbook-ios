//
//  CasualGamblingViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 02/03/2023.
//

import UIKit

class CasualGamblingViewController: UIViewController {

    // MARK: Private Properties
    private lazy var topView: UIView = Self.createTopView()
    private lazy var backButton: UIButton = Self.createBackButton()
    private lazy var topTitleLabel: UILabel = Self.createTopTitleLabel()
    private lazy var scrollView: UIScrollView = Self.createScrollView()
    private lazy var scrollContainerView: UIView = Self.createScrollContainerView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var textLabel: UILabel = Self.createTextLabel()

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

        // swiftlint:disable line_length
        self.textLabel.text = "Betsson aborde la question du jeu responsable au sérieux et prend des mesures pour aider les joueurs à jouer de manière sûre et saine. En effet, il est crucial de reconnaître qu'il existe une différence entre le jeu récréatif et le jeu problématique.\n\nLe jeu récréatif est généralement considéré comme une activité de loisir occasionnelle qui peut être agréable et amusante, mais qui ne prend pas le dessus sur la vie de la personne. Les joueurs récréatifs sont prudents dans leurs mises et ne jouent pas de manière compulsive ou excessive.\n\nLe jeu problématique, quant à lui, peut affecter la vie quotidienne d'une personne de manière négative. Les joueurs pathologiques ont du mal à contrôler leur comportement de jeu et peuvent continuer à jouer malgré les conséquences négatives qui en résultent, telles que des problèmes financiers, des conflits familiaux ou professionnels, des problèmes de santé mentale ou physique, etc.\n\nIl est donc important que les opérateurs de jeu en ligne tels que Betsson, mettent en place des mesures pour aider à prévenir et à détecter le jeu excessif. Cela peut inclure des limites de dépôt et de mise, des conseils de jeu responsable, ainsi que des options pour s'auto-exclure du site pendant une période de temps spécifiée.\n\nIl est également essentiel d'offrir un soutien et des ressources aux joueurs qui luttent contre le jeu problématique. Les joueurs peuvent bénéficier de programmes d'aide et de conseils en matière de jeu responsable, ainsi que d'un accès à des professionnels de la santé mentale pour les aider à surmonter leur dépendance.\n\nEn somme, la promotion d'un environnement de jeu sûr et sain est une responsabilité partagée entre les joueurs, les opérateurs de jeu en ligne et la société dans son ensemble.\n\nIl est parfois difficile de se rendre compte que le jeu n'est plus une source de plaisir mais commence à devenir un problème.\n\nNous t’invitons à faire un bilan sur Evalujeu, un site d'évaluation et de conseils personnalisés sur les pratiques de jeu."
    }

    // MARK: Layout and Theme
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
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

        self.titleLabel.textColor = UIColor.App.textPrimary

        self.textLabel.textColor = UIColor.App.textPrimary
    }
}

//
// MARK: - Actions
//
extension CasualGamblingViewController {
    @objc private func didTapBackButton() {
        self.navigationController?.popViewController(animated: true)
    }

}

//
// MARK: Subviews initialization and setup
//
extension CasualGamblingViewController {

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
        label.text = localized("casual_pathologic_gambling")
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

    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("casual_pathologic_question")
        label.font = AppFont.with(type: .bold, size: 16)
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }

    private static func createTextLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = ""
        label.font = AppFont.with(type: .bold, size: 16)
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }

    private func setupSubviews() {
        self.view.addSubview(self.topView)

        self.topView.addSubview(self.backButton)
        self.topView.addSubview(self.topTitleLabel)

        self.view.addSubview(self.scrollView)

        self.scrollView.addSubview(self.scrollContainerView)

        self.scrollContainerView.addSubview(self.titleLabel)
        self.scrollContainerView.addSubview(self.textLabel)

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

        // Content labels
        NSLayoutConstraint.activate([
            self.titleLabel.leadingAnchor.constraint(equalTo: self.scrollContainerView.leadingAnchor, constant: 20),
            self.titleLabel.trailingAnchor.constraint(equalTo: self.scrollContainerView.trailingAnchor, constant: -20),
            self.titleLabel.topAnchor.constraint(equalTo: self.scrollContainerView.topAnchor, constant: 30),

            self.textLabel.leadingAnchor.constraint(equalTo: self.scrollContainerView.leadingAnchor, constant: 20),
            self.textLabel.trailingAnchor.constraint(equalTo: self.scrollContainerView.trailingAnchor, constant: -20),
            self.textLabel.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 15),
            self.textLabel.bottomAnchor.constraint(equalTo: self.scrollContainerView.bottomAnchor, constant: -15)
        ])
    }

}
