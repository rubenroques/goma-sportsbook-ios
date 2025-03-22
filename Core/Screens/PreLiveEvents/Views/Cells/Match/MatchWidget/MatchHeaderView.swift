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
    private(set) var competitionNamePublisher = CurrentValueSubject<String?, Never>(nil)
    private(set) var countryImageNamePublisher = CurrentValueSubject<String?, Never>(nil)
    private(set) var isFavoritePublisher = CurrentValueSubject<Bool, Never>(false)
    private(set) var sportImageNamePublisher = CurrentValueSubject<String?, Never>(nil)

    // New hidden state publishers
    private(set) var isCountryFlagHiddenPublisher = CurrentValueSubject<Bool, Never>(false)
    private(set) var isSportIconHiddenPublisher = CurrentValueSubject<Bool, Never>(false)
    private(set) var isFavoriteIconHiddenPublisher = CurrentValueSubject<Bool, Never>(false)

    // MARK: Actions
    var favoriteAction: ((Bool) -> Void) = { _ in }

    // MARK: Initialization
    init(competitionName: String = "",
         countryImageName: String? = nil,
         isFavorite: Bool = false,
         sportImageName: String = "",
         favoriteAction: ((Bool) -> Void)? = nil) {

        self.competitionNamePublisher.send(competitionName)
        self.countryImageNamePublisher.send(countryImageName)
        self.isFavoritePublisher.send(isFavorite)
        self.sportImageNamePublisher.send(sportImageName)

        if let favoriteAction {
            self.favoriteAction = favoriteAction
        }
    }

    // MARK: Configuration
//    func configure(competitionName: String? = "",
//                   countryImageName: String? = nil,
//                   isFavorite: Bool = false,
//                   sportImageName: String = "",
//                   favoriteAction: ((Bool) -> Void)? = nil) {
//
//        self.competitionNamePublisher.send(competitionName)
//        self.countryImageNamePublisher.send(countryImageName)
//        self.isFavoritePublisher.send(isFavorite)
//        self.sportImageNamePublisher.send(sportImageName)
//
//        if let favoriteAction {
//            self.favoriteAction = favoriteAction
//        }
//    }

    func toggleFavorite() {
        let newState = !isFavoritePublisher.value
        isFavoritePublisher.send(newState)
        favoriteAction(newState)
    }

    // New methods to control hidden state
    func setCompetitionName(_ name: String?) {
        self.competitionNamePublisher.send(name)
    }
    func setCountryImageName(_ name: String?) {
        self.countryImageNamePublisher.send(name)
    }
    func setIsFavorite(_ favorite: Bool) {
        self.isFavoritePublisher.send(favorite)
    }
    func setSportImageName(_ name: String?) {
        self.sportImageNamePublisher.send(name)
    }

    func setCountryFlag(hidden: Bool) {
        isCountryFlagHiddenPublisher.send(hidden)
    }

    func setSportImage(hidden: Bool) {
        isSportIconHiddenPublisher.send(hidden)
    }

    func setFavoriteIcon(hidden: Bool) {
        isFavoriteIconHiddenPublisher.send(hidden)
    }
}

class MatchHeaderView: UIView {

    // MARK: Private Properties
    private lazy var favoritesIconImageView: UIImageView = Self.createFavoritesIconImageView()
    private lazy var sportTypeImageView: UIImageView = Self.createSportTypeImageView()
    private lazy var locationFlagImageView: UIImageView = Self.createLocationFlagImageView()
    private lazy var contentBaseView: UIView = Self.createContentBaseView()
    private lazy var competitionNameLabel: UILabel = Self.createEventNameLabel()
    private lazy var favoritesButton: UIButton = Self.createFavoritesButton()

    // MARK: ViewModel
    private var viewModel: MatchHeaderViewModel?
    private var cancellables = Set<AnyCancellable>()

    //
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

    override var intrinsicContentSize: CGSize {
        // Matching the height of the icons plus a bit of vertical padding
        return CGSize(width: UIView.noIntrinsicMetric, height: Self.height)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.locationFlagImageView.layer.cornerRadius = self.locationFlagImageView.frame.size.width / 2
        self.locationFlagImageView.layer.borderWidth = 0.5

        self.sportTypeImageView.layer.cornerRadius = self.sportTypeImageView.frame.size.width / 2
    }

    private func setupWithTheme() {
        self.backgroundColor = .clear

        self.competitionNameLabel.textColor = UIColor.App.textPrimary
        self.favoritesIconImageView.tintColor = UIColor.App.textPrimary

        self.favoritesButton.backgroundColor = .clear
        self.contentBaseView.backgroundColor = .clear

        self.contentBaseView.backgroundColor = .clear

        self.sportTypeImageView.backgroundColor = .clear

        self.locationFlagImageView.backgroundColor = .clear
        self.locationFlagImageView.layer.borderColor = UIColor.App.highlightPrimaryContrast.cgColor
    }

    // MARK: Configuration
    func configure(with viewModel: MatchHeaderViewModel) {
        self.viewModel = viewModel
        self.setupBindings()
    }

    func cleanupForReuse() {
        self.viewModel = nil

        self.competitionNameLabel.text = nil
        self.locationFlagImageView.image = nil
        self.favoritesIconImageView.image = nil
        self.sportTypeImageView.image = nil

        self.cancellables.removeAll()
    }

    private func setupBindings() {
        guard let viewModel = viewModel else { return }

        // Clear previous cancellables
        self.cancellables.removeAll()

        // Bind event name
        viewModel.competitionNamePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] name in
                self?.competitionNameLabel.text = name
            }
            .store(in: &self.cancellables)

        // Bind country ISO code (for flag)
        viewModel.countryImageNamePublisher
            .combineLatest(viewModel.isCountryFlagHiddenPublisher)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] countryImageName, isHidden in
                self?.locationFlagImageView.image = countryImageName.flatMap { UIImage(named: $0) }
                self?.locationFlagImageView.isHidden = isHidden
            }
            .store(in: &self.cancellables)

        // Bind favorite state
        viewModel.isFavoritePublisher
            .combineLatest(viewModel.isFavoriteIconHiddenPublisher)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isFavorite, isHidden in
                let imageName = isFavorite ? "selected_favorite_icon" : "unselected_favorite_icon"
                self?.favoritesIconImageView.image = UIImage(named: imageName)
                self?.favoritesIconImageView.isHidden = isHidden
                self?.favoritesButton.isHidden = isHidden
            }
            .store(in: &self.cancellables)

        // Bind sport image
        viewModel.sportImageNamePublisher
            .combineLatest(viewModel.isSportIconHiddenPublisher)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] sportImageName, isHidden in
                if let sportImageName, !sportImageName.isEmpty {
                    self?.sportTypeImageView.image = UIImage(named: sportImageName)
                } else {
                    self?.sportTypeImageView.image = nil
                }
                self?.sportTypeImageView.isHidden = isHidden
            }
            .store(in: &self.cancellables)

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

        self.contentBaseView.addSubview(self.competitionNameLabel)

        self.addSubview(self.favoritesButton)

        self.initConstraints()

        self.favoritesButton.addTarget(self, action: #selector(favoriteButtonTapped), for: .touchUpInside)
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
            self.contentBaseView.trailingAnchor.constraint(equalTo: self.trailingAnchor),

            self.competitionNameLabel.leadingAnchor.constraint(equalTo: self.contentBaseView.leadingAnchor),
            self.competitionNameLabel.centerYAnchor.constraint(equalTo: self.contentBaseView.centerYAnchor, constant: 1),
            self.competitionNameLabel.trailingAnchor.constraint(equalTo: self.contentBaseView.trailingAnchor, constant: -1),

            // Favorites button - invisible but covering the favorites icon for taps
            self.favoritesButton.centerXAnchor.constraint(equalTo: self.favoritesIconImageView.centerXAnchor),
            self.favoritesButton.centerYAnchor.constraint(equalTo: self.favoritesIconImageView.centerYAnchor),
            self.favoritesButton.widthAnchor.constraint(equalToConstant: 40),
            self.favoritesButton.heightAnchor.constraint(equalToConstant: 40),

            self.heightAnchor.constraint(equalToConstant: Self.height),
        ])
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
                        competitionName: "Premier League",
                        countryImageName: "GB",
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
                        competitionName: "La Liga",
                        countryImageName: "ES",
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
                        competitionName: "Serie A",
                        countryImageName: "IT",
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
