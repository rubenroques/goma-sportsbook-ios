//
//  UserProfileInfoViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 20/09/2022.
//

import UIKit
import Combine

class UserProfileInfoViewModel {

    var userId: String
    var userProfileInfo: UserProfileInfo?
    var isLoadingPublisher: CurrentValueSubject<Bool, Never> = .init(false)
    var userProfileInfoStatePublisher: CurrentValueSubject<UserProfileState, Never> = .init(.loading)

    private var cancellables = Set<AnyCancellable>()

    init(userId: String) {
        self.userId = userId

    }

    func setUserProfileInfoState(userProfileState: UserProfileState, userProfileInfo: UserProfileInfo? = nil) {

        switch userProfileState {
        case .loaded:
            self.userProfileInfo = userProfileInfo

            self.isLoadingPublisher.send(false)

            self.userProfileInfoStatePublisher.send(.loaded)
        case .failed:
            self.isLoadingPublisher.send(false)

            self.userProfileInfoStatePublisher.send(.failed)
        case .loading:
            self.isLoadingPublisher.send(true)
        }

    }

}

class UserProfileInfoViewController: UIViewController {

    // MARK: Private properties
    private lazy var scrollView: UIScrollView = Self.createScrollView()
    private lazy var scrollContainerView: UIView = Self.createScrollContainerView()
    private lazy var simpleCardsStackView: UIStackView = Self.createSimpleCardsStackView()
    private lazy var loadingBaseView: UIView = Self.createLoadingBaseView()
    private lazy var loadingActivityIndicatorView: UIActivityIndicatorView = Self.createLoadingActivityIndicatorView()

    private var viewModel: UserProfileInfoViewModel
    private var cancellables = Set<AnyCancellable>()

    // MARK: Public properties
    var isLoading: Bool = false {
        didSet {
            if isLoading {
                self.loadingBaseView.isHidden = false
                self.loadingActivityIndicatorView.startAnimating()
            }
            else {
                self.loadingBaseView.isHidden = true
                self.loadingActivityIndicatorView.stopAnimating()
            }
        }
    }

    // MARK: - Lifetime and Cycle
    init(viewModel: UserProfileInfoViewModel) {
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)

        self.title = "Info"

    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupSubviews()
        self.setupWithTheme()

        self.isLoading = true

        self.bind(toViewModel: self.viewModel)
    }

    // MARK: - Layout and Theme
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    private func setupWithTheme() {
        self.view.backgroundColor = UIColor.App.backgroundPrimary

        self.scrollView.backgroundColor = .clear

        self.scrollContainerView.backgroundColor = .clear

        self.simpleCardsStackView.backgroundColor = .clear

        self.loadingBaseView.backgroundColor = UIColor.App.backgroundPrimary

        self.loadingActivityIndicatorView.color = UIColor.lightGray
    }

    // MARK: Binding
    private func bind(toViewModel viewModel: UserProfileInfoViewModel) {

        viewModel.isLoadingPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] isLoading in
                self?.isLoading = isLoading
            })
            .store(in: &cancellables)

        viewModel.userProfileInfoStatePublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] userProfileInfoState in

                switch userProfileInfoState {
                case .loaded:
                    self?.configureCards()
                case .failed:
                    ()
                case .loading:
                    ()
                }
            })
            .store(in: &cancellables)
    }

    // MARK: Functions
    private func configureCards() {
        if let userProfileInfo = self.viewModel.userProfileInfo {

            let accumulatedCardView = UserInfoSimpleCardView()
            accumulatedCardView.configure(title: localized("accumulated_odds_winning"), value: "\(userProfileInfo.rankings.accumulatedWins)", iconType: .accumulated)

            let winsCardView = UserInfoSimpleCardView()
            winsCardView.configure(title: localized("best_consecutive_wins"), value: "\(userProfileInfo.rankings.consecutiveWins)", iconType: .wins)

            let highestOddCardView = UserInfoSimpleCardView()
            highestOddCardView.configure(title: localized("highest_odd"), value: "\(userProfileInfo.rankings.highestOdd)", iconType: .highest)
            
            self.simpleCardsStackView.addArrangedSubview(accumulatedCardView)
            self.simpleCardsStackView.addArrangedSubview(winsCardView)
            self.simpleCardsStackView.addArrangedSubview(highestOddCardView)

            if userProfileInfo.sportsPerc.isNotEmpty {

                let sportsPercentageCardView = UserInfoMultipleCardView()
                sportsPercentageCardView.configure(title: localized("percentage_sports"), iconType: .percentage, sportsData: userProfileInfo.sportsPerc)

                self.simpleCardsStackView.addArrangedSubview(sportsPercentageCardView)

            }
        }

    }

    func getViewModel() -> UserProfileInfoViewModel {
        return self.viewModel
    }

}

//
// MARK: - Subviews Initialization and Setup
//
extension UserProfileInfoViewController {

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

    private static func createSimpleCardsStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.spacing = 8
        return stackView
    }

    private static func createLoadingBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createLoadingActivityIndicatorView() -> UIActivityIndicatorView {
        let activityIndicatorView = UIActivityIndicatorView.init(style: .large)
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.stopAnimating()
        return activityIndicatorView
    }

    private func setupSubviews() {

        self.view.addSubview(self.scrollView)

        self.scrollView.addSubview(self.scrollContainerView)

        self.scrollContainerView.addSubview(self.simpleCardsStackView)

        self.view.addSubview(self.loadingBaseView)

        self.loadingBaseView.addSubview(self.loadingActivityIndicatorView)

        self.initConstraints()
    }

    private func initConstraints() {

        // Scroll view
        NSLayoutConstraint.activate([
            self.scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.scrollView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            self.scrollView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),

            self.scrollContainerView.leadingAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.leadingAnchor),
            self.scrollContainerView.trailingAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.trailingAnchor),
            self.scrollContainerView.topAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.topAnchor),
            self.scrollContainerView.bottomAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.bottomAnchor),
            self.scrollContainerView.widthAnchor.constraint(equalTo: self.scrollView.frameLayoutGuide.widthAnchor)
        ])

        // Simple cards stack view
        NSLayoutConstraint.activate([
            self.simpleCardsStackView.leadingAnchor.constraint(equalTo: self.scrollContainerView.leadingAnchor, constant: 15),
            self.simpleCardsStackView.trailingAnchor.constraint(equalTo: self.scrollContainerView.trailingAnchor, constant: -15),
            self.simpleCardsStackView.topAnchor.constraint(equalTo: self.scrollContainerView.topAnchor, constant: 15),
            self.simpleCardsStackView.bottomAnchor.constraint(equalTo: self.scrollContainerView.bottomAnchor, constant: -15)
        ])

        // Loading view
        NSLayoutConstraint.activate([
            self.loadingActivityIndicatorView.centerYAnchor.constraint(equalTo: self.loadingBaseView.centerYAnchor),
            self.loadingActivityIndicatorView.centerXAnchor.constraint(equalTo: self.loadingBaseView.centerXAnchor),

            self.view.leadingAnchor.constraint(equalTo: self.loadingBaseView.leadingAnchor),
            self.view.trailingAnchor.constraint(equalTo: self.loadingBaseView.trailingAnchor),
            self.view.topAnchor.constraint(equalTo: self.loadingBaseView.topAnchor),
            self.view.bottomAnchor.constraint(equalTo: self.loadingBaseView.bottomAnchor)
        ])

    }

}
