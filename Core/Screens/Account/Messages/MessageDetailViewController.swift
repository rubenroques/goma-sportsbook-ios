//
//  MessageDetailViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 26/07/2022.
//

import UIKit

class MessageDetailViewController: UIViewController {

    // MARK: Private Properties
    private lazy var topView: UIView = Self.createTopView()
    private lazy var backButton: UIButton = Self.createBackButton()
    private lazy var topTitleLabel: UILabel = Self.createTopTitleLabel()
    private lazy var headerView: UIView = Self.createHeaderView()
    private lazy var headerTitleLabel: UILabel = Self.createHeaderTitleLabel()
    private lazy var deleteButton: UIButton = Self.createDeleteButton()
    private lazy var headerSeparatorView: UIView = Self.createHeaderSeparatorView()

    private lazy var scrollView: UIScrollView = Self.createScrollView()
    private lazy var scrollContainerView: UIView = Self.createScrollContainerView()

    private lazy var regularMessageHeaderView: UIView = Self.createRegularMessageHeaderView()
    private lazy var regularMessageTitleLabel: UILabel = Self.createRegularMessageTitleLabel()
    private lazy var regularMessageSubtitleLabel: UILabel = Self.createRegularMessageSubtitleLabel()
    private lazy var regularMessageImageView: UIImageView = Self.createRegularMessageImageView()

    private lazy var messageDescriptionLabel: UILabel = Self.createMessageDescriptionLabel()

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

        self.backButton.addTarget(self, action: #selector(didTapBackButton), for: .primaryActionTriggered)

        self.deleteButton.addTarget(self, action: #selector(didTapDeleteButton), for: .primaryActionTriggered)

        self.regularMessageImageView.image = UIImage(named: "goma_message_banner")
        //self.bind(toViewModel: self.viewModel)

        // TEMP
        self.deleteButton.isHidden = true

    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        self.regularMessageImageView.layer.masksToBounds = true
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

        self.headerView.backgroundColor = UIColor.App.backgroundPrimary

        self.headerTitleLabel.textColor = UIColor.App.textSecondary

        self.deleteButton.backgroundColor = .clear

        self.deleteButton.setTitleColor(UIColor.App.highlightSecondary, for: UIControl.State.normal)

        self.headerSeparatorView.backgroundColor = UIColor.App.separatorLine

        self.scrollView.backgroundColor = .clear

        self.scrollContainerView.backgroundColor = .clear

        self.regularMessageTitleLabel.textColor = UIColor.App.textPrimary

        self.regularMessageSubtitleLabel.textColor = UIColor.App.textSecondary

        self.messageDescriptionLabel.textColor = UIColor.App.textPrimary
    }

    // MARK: Actions
    @objc private func didTapBackButton() {
        self.navigationController?.popViewController(animated: true)
    }

    @objc private func didTapDeleteButton() {
        print("Tapped Delete!")
    }
}

//
// MARK: Subviews initialization and setup
//
extension MessageDetailViewController {

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
        label.text = localized("messages")
        label.font = AppFont.with(type: .bold, size: 18)
        label.textAlignment = .center
        return label
    }

    private static func createHeaderView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createHeaderTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Header Title"
        label.font = AppFont.with(type: .semibold, size: 12)
        label.textAlignment = .left
        return label
    }

    private static func createDeleteButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(localized("delete"), for: .normal)
        button.titleLabel?.font = AppFont.with(type: .semibold, size: 12)
        return button
    }

    private static func createHeaderSeparatorView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
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

    private static func createRegularMessageHeaderView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createRegularMessageTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Message Title"
        label.font = AppFont.with(type: .bold, size: 18)
        label.textAlignment = .left
        label.numberOfLines = 0
        label.setLineSpacing(lineSpacing: 3)
        return label
    }

    private static func createRegularMessageSubtitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Message Subtitle"
        label.font = AppFont.with(type: .semibold, size: 11)
        label.textAlignment = .left
        return label
    }

    private static func createRegularMessageImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        return imageView
    }

    private static func createMessageDescriptionLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        // swiftlint:disable line_length
        label.text = "Sportsbook operator William Hill and Monumental Sports executives celebrated the opening of a 20,000-square-foot sportsbook inside Capital One Arena in Washington D.C.\nThe arena won the race last Wednesday to become the first U.S. pro sports venue containing a sportsbook.\n“I think we should be utilizing more of this space,” Leonsis said in a Washington Post story. “Because when you go into it, it looks and feels like what sports’ future should look and feel like: lots of data, lots of comfortable settings, lots of televisions, lots of ways to learn about gaming.”\nCities including Phoenix are following a similar plan, with a sportsbook inside Phoenix Suns Arena targeted to open this fall. And baseball’s Arizona Diamondbacks plan to partner with an operator to open a sportsbook downtown, across the street from their ballpark.\n“We really think this is going to be a model for these types of experiences inside professional sports arenas,” said Dan Shapiro, William Hill’s vice president of strategy and business development."
        label.font = AppFont.with(type: .medium, size: 15)
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }

    private func setupSubviews() {
        self.view.addSubview(self.topView)

        self.topView.addSubview(self.backButton)
        self.topView.addSubview(self.topTitleLabel)
        self.topView.bringSubviewToFront(self.topTitleLabel)

        self.view.addSubview(self.headerView)

        self.headerView.addSubview(self.headerTitleLabel)
        self.headerView.addSubview(self.deleteButton)
        self.headerView.addSubview(self.headerSeparatorView)

        self.view.addSubview(self.scrollView)

        self.scrollView.addSubview(self.scrollContainerView)

        self.scrollContainerView.addSubview(self.regularMessageHeaderView)

        self.regularMessageHeaderView.addSubview(self.regularMessageTitleLabel)
        self.regularMessageHeaderView.addSubview(self.regularMessageSubtitleLabel)
        self.regularMessageHeaderView.addSubview(self.regularMessageImageView)

        self.scrollContainerView.addSubview(self.messageDescriptionLabel)

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

        // Header view
        NSLayoutConstraint.activate([
            self.headerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 25),
            self.headerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -25),
            self.headerView.topAnchor.constraint(equalTo: self.topView.bottomAnchor, constant: 5),

            self.headerTitleLabel.leadingAnchor.constraint(equalTo: self.headerView.leadingAnchor, constant: 14),
            self.headerTitleLabel.topAnchor.constraint(equalTo: self.headerView.topAnchor, constant: 5),

            self.deleteButton.trailingAnchor.constraint(equalTo: self.headerView.trailingAnchor),
            self.deleteButton.heightAnchor.constraint(equalToConstant: 40),
            self.deleteButton.centerYAnchor.constraint(equalTo: self.headerTitleLabel.centerYAnchor),

            self.headerSeparatorView.leadingAnchor.constraint(equalTo: self.headerView.leadingAnchor),
            self.headerSeparatorView.trailingAnchor.constraint(equalTo: self.headerView.trailingAnchor),
            self.headerSeparatorView.topAnchor.constraint(equalTo: self.headerTitleLabel.bottomAnchor, constant: 8),
            self.headerSeparatorView.bottomAnchor.constraint(equalTo: self.headerView.bottomAnchor),
            self.headerSeparatorView.heightAnchor.constraint(equalToConstant: 1)
        ])

        // Scroll view
        NSLayoutConstraint.activate([
            self.scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.scrollView.topAnchor.constraint(equalTo: self.headerView.bottomAnchor, constant: 10),
            self.scrollView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),

            self.scrollContainerView.leadingAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.leadingAnchor),
            self.scrollContainerView.trailingAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.trailingAnchor),
            self.scrollContainerView.topAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.topAnchor),
            self.scrollContainerView.bottomAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.bottomAnchor),
            self.scrollContainerView.widthAnchor.constraint(equalTo: self.scrollView.frameLayoutGuide.widthAnchor)
        ])

        // Regular header view
        NSLayoutConstraint.activate([
            self.regularMessageHeaderView.leadingAnchor.constraint(equalTo: self.scrollContainerView.leadingAnchor, constant: 40),
            self.regularMessageHeaderView.trailingAnchor.constraint(equalTo: self.scrollContainerView.trailingAnchor, constant: -40),
            self.regularMessageHeaderView.topAnchor.constraint(equalTo: self.scrollContainerView.topAnchor),

            self.regularMessageTitleLabel.leadingAnchor.constraint(equalTo: self.regularMessageHeaderView.leadingAnchor),
            self.regularMessageTitleLabel.trailingAnchor.constraint(equalTo: self.regularMessageHeaderView.trailingAnchor),
            self.regularMessageTitleLabel.topAnchor.constraint(equalTo: self.regularMessageHeaderView.topAnchor, constant: 10),

            self.regularMessageSubtitleLabel.leadingAnchor.constraint(equalTo: self.regularMessageHeaderView.leadingAnchor),
            self.regularMessageSubtitleLabel.trailingAnchor.constraint(equalTo: self.regularMessageHeaderView.trailingAnchor),
            self.regularMessageSubtitleLabel.topAnchor.constraint(equalTo: self.regularMessageTitleLabel.bottomAnchor, constant: 20),

            self.regularMessageImageView.leadingAnchor.constraint(equalTo: self.regularMessageHeaderView.leadingAnchor),
            self.regularMessageImageView.trailingAnchor.constraint(equalTo: self.regularMessageHeaderView.trailingAnchor),
            self.regularMessageImageView.topAnchor.constraint(equalTo: self.regularMessageSubtitleLabel.bottomAnchor, constant: 25),
            self.regularMessageImageView.bottomAnchor.constraint(equalTo: self.regularMessageHeaderView.bottomAnchor, constant: -10)
        ])

        NSLayoutConstraint.activate([
            self.messageDescriptionLabel.leadingAnchor.constraint(equalTo: self.scrollContainerView.leadingAnchor, constant: 40),
            self.messageDescriptionLabel.trailingAnchor.constraint(equalTo: self.scrollContainerView.trailingAnchor, constant: -40),
            self.messageDescriptionLabel.topAnchor.constraint(equalTo: self.regularMessageHeaderView.bottomAnchor, constant: 30),
            self.messageDescriptionLabel.bottomAnchor.constraint(equalTo: self.scrollContainerView.bottomAnchor, constant: -20)
        ])

    }

}
