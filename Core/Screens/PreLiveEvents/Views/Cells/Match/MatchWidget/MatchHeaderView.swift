//
//  MatchHeaderView.swift
//  Sportsbook
//
//  Created by Claude on 2024-07-02.
//

import UIKit
import SwiftUI
import Combine

// MARK: - ViewModel
class MatchHeaderViewModel {
    // MARK: Publishers
    private(set) var eventNamePublisher = CurrentValueSubject<String, Never>("")
    private(set) var countryISOCodePublisher = CurrentValueSubject<String, Never>("")
    private(set) var numberOfBetsPublisher = CurrentValueSubject<Int?, Never>(nil)
    private(set) var isFavoritePublisher = CurrentValueSubject<Bool, Never>(false)
    private(set) var sportImageNamePublisher = CurrentValueSubject<String, Never>("")

    // MARK: Actions
    var favoriteAction: ((Bool) -> Void)?

    // MARK: Initialization
    init(eventName: String = "",
         countryISOCode: String = "",
         numberOfBets: Int? = nil,
         isFavorite: Bool = false,
         sportImageName: String = "",
         favoriteAction: ((Bool) -> Void)? = nil) {

        self.eventNamePublisher.send(eventName)
        self.countryISOCodePublisher.send(countryISOCode)
        self.numberOfBetsPublisher.send(numberOfBets)
        self.isFavoritePublisher.send(isFavorite)
        self.sportImageNamePublisher.send(sportImageName)
        self.favoriteAction = favoriteAction
    }

    // MARK: Configuration
    func configure(eventName: String,
                   countryISOCode: String,
                   numberOfBets: Int? = nil,
                   isFavorite: Bool = false,
                   sportImageName: String = "",
                   favoriteAction: ((Bool) -> Void)? = nil) {

        self.eventNamePublisher.send(eventName)
        self.countryISOCodePublisher.send(countryISOCode)
        self.numberOfBetsPublisher.send(numberOfBets)
        self.isFavoritePublisher.send(isFavorite)
        self.sportImageNamePublisher.send(sportImageName)
        self.favoriteAction = favoriteAction
    }

    func toggleFavorite() {
        let newState = !isFavoritePublisher.value
        isFavoritePublisher.send(newState)
        favoriteAction?(newState)
    }
}

class MatchHeaderView: UIView {

    // MARK: Private Properties
    private lazy var favoritesIconImageView: UIImageView = Self.createFavoritesIconImageView()
    private lazy var sportTypeImageView: UIImageView = Self.createSportTypeImageView()
    private lazy var locationFlagImageView: UIImageView = Self.createLocationFlagImageView()
    private lazy var contentBaseView: UIView = Self.createContentBaseView()
    private lazy var eventNameLabel: UILabel = Self.createEventNameLabel()
    private lazy var numberOfBetsLabel: UILabel = Self.createNumberOfBetsLabel()
    private lazy var favoritesButton: UIButton = Self.createFavoritesButton()

    // MARK: ViewModel
    private var viewModel: MatchHeaderViewModel?
    private var cancellables = Set<AnyCancellable>()

    private static let height: CGFloat = 17

    // MARK: Lifetime Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)

        self.setupSubviews()
        self.setupWithTheme()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.setupSubviews()
        self.setupWithTheme()
    }

    private func setupWithTheme() {
        self.backgroundColor = .clear

        self.eventNameLabel.textColor = UIColor.App.textPrimary
        self.numberOfBetsLabel.textColor = UIColor.App.textPrimary
        self.favoritesIconImageView.tintColor = UIColor.App.textPrimary

        self.favoritesButton.backgroundColor = .clear
        self.contentBaseView.backgroundColor = .clear

        self.contentBaseView.backgroundColor = .clear
    }

    // MARK: Configuration
    func configure(with viewModel: MatchHeaderViewModel) {
        self.viewModel = viewModel
        self.setupBindings()
    }

    private func setupBindings() {
        guard let viewModel = viewModel else { return }

        // Clear previous cancellables
        cancellables.removeAll()

        // Bind event name
        viewModel.eventNamePublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] name in
                self?.eventNameLabel.text = name
            }
            .store(in: &cancellables)

        // Bind country ISO code (for flag)
        viewModel.countryISOCodePublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] isoCode in
                self?.locationFlagImageView.image = UIImage(named: Assets.flagName(withCountryCode: isoCode))
                self?.locationFlagImageView.isHidden = isoCode.isEmpty
            }
            .store(in: &cancellables)

        // Bind number of bets
        viewModel.numberOfBetsPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] numberOfBets in
                if let bets = numberOfBets {
                    self?.numberOfBetsLabel.text = "\(bets)"
                    self?.numberOfBetsLabel.isHidden = false
                }
                else {
                    self?.numberOfBetsLabel.isHidden = true
                }
            }
            .store(in: &cancellables)

        // Bind favorite state
        viewModel.isFavoritePublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] isFavorite in
                let imageName = isFavorite ? "selected_favorite_icon" : "unselected_favorite_icon"
                self?.favoritesIconImageView.image = UIImage(named: imageName)
            }
            .store(in: &cancellables)

        // Bind sport image
        viewModel.sportImageNamePublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] sportImageName in
                if !sportImageName.isEmpty {
                    self?.sportTypeImageView.image = UIImage(named: "sport_type_icon_\(sportImageName)")
                    self?.sportTypeImageView.isHidden = false
                }
                else {
                    self?.sportTypeImageView.isHidden = true
                }
            }
            .store(in: &cancellables)

        // Add button action
        favoritesButton.addTarget(self, action: #selector(favoriteButtonTapped), for: .touchUpInside)
    }

    @objc private func favoriteButtonTapped() {
        viewModel?.toggleFavorite()
    }
}

// MARK: - Factory Methods
extension MatchHeaderView {
    private static func createFavoritesIconImageView() -> UIImageView {
        let imageView: UIImageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "unselected_favorite_icon")
        return imageView
    }

    private static func createSportTypeImageView() -> UIImageView {
        let imageView: UIImageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }

    private static func createLocationFlagImageView() -> UIImageView {
        let imageView: UIImageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.masksToBounds = true
        return imageView
    }

    private static func createContentBaseView() -> UIView {
        let view: UIView = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }

    private static func createEventNameLabel() -> UILabel {
        let label: UILabel = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Roboto-Medium", size: 11)
        label.numberOfLines = 1
        return label
    }

    private static func createNumberOfBetsLabel() -> UILabel {
        let label: UILabel = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .bold, size: 11)
        label.numberOfLines = 1
        label.textAlignment = .right
        return label
    }

    private static func createFavoritesButton() -> UIButton {
        let button: UIButton = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        return button
    }

    // MARK: Layout Setup
    private func setupSubviews() {

        self.addSubview(self.favoritesIconImageView)
        self.addSubview(self.sportTypeImageView)
        self.addSubview(self.locationFlagImageView)
        self.addSubview(self.contentBaseView)

        self.contentBaseView.addSubview(self.eventNameLabel)

        self.addSubview(self.numberOfBetsLabel)
        self.addSubview(self.favoritesButton)

        self.initConstraints()

        // Set initial state
        self.numberOfBetsLabel.isHidden = true
    }

    private func initConstraints() {
        NSLayoutConstraint.activate([
            // Match the XIB structure
            self.favoritesIconImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.favoritesIconImageView.topAnchor.constraint(equalTo: self.topAnchor),
            self.favoritesIconImageView.heightAnchor.constraint(equalTo: self.heightAnchor),
            self.favoritesIconImageView.widthAnchor.constraint(equalTo: self.favoritesIconImageView.heightAnchor),

            self.sportTypeImageView.leadingAnchor.constraint(equalTo: self.favoritesIconImageView.trailingAnchor, constant: 7),
            self.sportTypeImageView.centerYAnchor.constraint(equalTo: self.favoritesIconImageView.centerYAnchor),
            self.sportTypeImageView.heightAnchor.constraint(equalTo: self.heightAnchor),
            self.sportTypeImageView.widthAnchor.constraint(equalTo: self.sportTypeImageView.heightAnchor),

            self.locationFlagImageView.leadingAnchor.constraint(equalTo: self.sportTypeImageView.trailingAnchor, constant: 7),
            self.locationFlagImageView.centerYAnchor.constraint(equalTo: self.favoritesIconImageView.centerYAnchor),
            self.locationFlagImageView.heightAnchor.constraint(equalTo: self.heightAnchor),
            self.locationFlagImageView.widthAnchor.constraint(equalTo: self.locationFlagImageView.heightAnchor),

            self.contentBaseView.leadingAnchor.constraint(equalTo: self.locationFlagImageView.trailingAnchor, constant: 7),
            self.contentBaseView.topAnchor.constraint(equalTo: self.topAnchor),
            self.contentBaseView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            self.contentBaseView.trailingAnchor.constraint(equalTo: self.numberOfBetsLabel.leadingAnchor, constant: -5),

            self.eventNameLabel.leadingAnchor.constraint(equalTo: self.contentBaseView.leadingAnchor),
            self.eventNameLabel.centerYAnchor.constraint(equalTo: self.contentBaseView.centerYAnchor, constant: 1),
            self.eventNameLabel.trailingAnchor.constraint(equalTo: self.contentBaseView.trailingAnchor, constant: -1),

            self.numberOfBetsLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.numberOfBetsLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),

            // Favorites button - invisible but covering the favorites icon for taps
            self.favoritesButton.centerXAnchor.constraint(equalTo: self.favoritesIconImageView.centerXAnchor),
            self.favoritesButton.centerYAnchor.constraint(equalTo: self.favoritesIconImageView.centerYAnchor),
            self.favoritesButton.widthAnchor.constraint(equalToConstant: 40),
            self.favoritesButton.heightAnchor.constraint(equalToConstant: 40),

            self.heightAnchor.constraint(equalToConstant: Self.height),
        ])
    }

    override var intrinsicContentSize: CGSize {
        // Matching the height of the icons plus a bit of vertical padding
        return CGSize(width: UIView.noIntrinsicMetric, height: Self.height)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.locationFlagImageView.layer.cornerRadius = self.locationFlagImageView.frame.size.width / 2
    }
}

// MARK: - SwiftUI Previews
@available(iOS 17.0, *)
#Preview("MatchHeaderView - All States") {
    ScrollView {
        VStack(spacing: 18) {
            VStack(alignment: .leading) {
                Text("Premier League")
                    .font(.caption)
                    .foregroundColor(.gray)

                PreviewUIView {
                    let view = MatchHeaderView()
                    let viewModel = MatchHeaderViewModel(
                        eventName: "Premier League",
                        countryISOCode: "GB",
                        numberOfBets: nil,
                        isFavorite: false,
                        sportImageName: "1"
                    )
                    view.configure(with: viewModel)
                    return view
                }
                .frame(width: 300)
                .padding()
                .background(Color(UIColor.App.backgroundSecondary))
            }

            VStack(alignment: .leading) {
                Text("La Liga with bet count")
                    .font(.caption)
                    .foregroundColor(.gray)

                PreviewUIView {
                    let view = MatchHeaderView()
                    let viewModel = MatchHeaderViewModel(
                        eventName: "La Liga",
                        countryISOCode: "ES",
                        numberOfBets: 25,
                        isFavorite: true,
                        sportImageName: "1"
                    )
                    view.configure(with: viewModel)
                    return view
                }
                .frame(width: 300)
                .padding()
                .background(Color(UIColor.App.backgroundSecondary))
            }

            VStack(alignment: .leading) {
                Text("Serie A with basketball icon")
                    .font(.caption)
                    .foregroundColor(.gray)

                PreviewUIView {
                    let view = MatchHeaderView()
                    let viewModel = MatchHeaderViewModel(
                        eventName: "Serie A",
                        countryISOCode: "IT",
                        numberOfBets: nil,
                        isFavorite: true,
                        sportImageName: "8"
                    )
                    view.configure(with: viewModel)
                    return view
                }
                .frame(width: 300)
                .padding()
                .background(Color(UIColor.App.backgroundSecondary))
            }
        }
        .padding()
    }
}
