import UIKit
import SwiftUI
import Combine

public class MatchHeaderView: UIView {

    // MARK: - Private Properties
    private lazy var favoritesIconImageView: UIImageView = Self.createFavoritesIconImageView()
    private lazy var sportTypeImageView: UIImageView = Self.createSportTypeImageView()
    private lazy var locationFlagImageView: UIImageView = Self.createLocationFlagImageView()
    private lazy var competitionNameLabel: UILabel = Self.createCompetitionNameLabel()
    private lazy var favoritesButton: UIButton = Self.createFavoritesButton()
    private lazy var matchTimeLabel: UILabel = Self.createMatchTimeLabel()
    private lazy var liveIndicatorView: UIView = Self.createLiveIndicatorView()
    private lazy var rightContentStackView: UIStackView = Self.createRightContentStackView()
    private lazy var leftContentStackView: UIStackView = Self.createLeftContentStackView()
    private lazy var mainContentStackView: UIStackView = Self.createMainContentStackView()

    // MARK: - ViewModel & Reactive
    private var viewModel: MatchHeaderViewModelProtocol?
    private var imageResolver: MatchHeaderImageResolver?
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Constants
    private static let height: CGFloat = 17
    private static let iconSpacing: CGFloat = 8
    private static let buttonTouchArea: CGFloat = 40

    // MARK: - Initialization
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
        setupConstraints()
        setupStyling()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupSubviews()
        setupConstraints()
        setupStyling()
    }

    public convenience init(viewModel: MatchHeaderViewModelProtocol, imageResolver: MatchHeaderImageResolver = DefaultMatchHeaderImageResolver()) {
        self.init(frame: .zero)
        
        self.viewModel = viewModel
        self.imageResolver = imageResolver
        setupBindings()
    }

    public override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: Self.height)
    }

    public override func layoutSubviews() {
        super.layoutSubviews()

        // Ensure the country flag image view is circular
        updateLocationFlagCornerRadius()
    }

    private func updateLocationFlagCornerRadius() {
        let radius = locationFlagImageView.frame.width / 2
        locationFlagImageView.layer.cornerRadius = radius
        locationFlagImageView.clipsToBounds = true
        locationFlagImageView.layer.masksToBounds = true
    }

    // MARK: - Public Configuration
    public func configure(with viewModel: MatchHeaderViewModelProtocol) {
        self.viewModel = viewModel
        setupBindings()
    }

    public func cleanupForReuse() {
        viewModel = nil
        competitionNameLabel.text = nil
        matchTimeLabel.text = nil

        locationFlagImageView.image = UIImage(systemName: "globe")

        let configuration = UIImage.SymbolConfiguration(weight: .semibold)
        favoritesIconImageView.image = UIImage(systemName: "star", withConfiguration: configuration)?.withRenderingMode(.alwaysTemplate)

        sportTypeImageView.image = UIImage(systemName: "soccerball")

        cancellables.removeAll()
    }
}

// MARK: - Private Setup Methods
extension MatchHeaderView {

    private func setupStyling() {
        self.translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear

        // Use StyleProvider for consistent theming
        competitionNameLabel.textColor = StyleProvider.Color.highlightPrimary
        matchTimeLabel.textColor = StyleProvider.Color.highlightTertiary

        favoritesButton.backgroundColor = .clear
    }

    private func setupBindings() {
        guard let viewModel = viewModel else { return }

        // Clear previous cancellables
        cancellables.removeAll()

        // Bind competition name
        viewModel.competitionNamePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] name in
                self?.competitionNameLabel.text = name
            }
            .store(in: &cancellables)

        // Bind country flag image - use imageResolver if available
        viewModel.countryFlagImageNamePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] imageName in
                if let imageName = imageName, let imageResolver = self?.imageResolver {
                    // Use imageResolver to get the image
                    self?.locationFlagImageView.image = imageResolver.countryFlagImage(for: imageName)
                    self?.locationFlagImageView.tintColor = nil // Remove tint for custom images
                } else {
                    // Fallback to system image
                    self?.locationFlagImageView.image = UIImage(systemName: "globe")
                    self?.locationFlagImageView.tintColor = StyleProvider.Color.textSecondary
                }
            }
            .store(in: &cancellables)

        // Bind sport icon image - use imageResolver if available
        viewModel.sportIconImageNamePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] imageName in
                if let imageName = imageName, let imageResolver = self?.imageResolver {
                    // Use imageResolver to get the image
                    self?.sportTypeImageView.image = imageResolver.sportIconImage(for: imageName)?.withRenderingMode(.alwaysTemplate)
                    self?.sportTypeImageView.tintColor = StyleProvider.Color.highlightPrimary
                } else {
                    // Fallback to system image
                    self?.sportTypeImageView.image = UIImage(systemName: "soccerball")
                    self?.sportTypeImageView.tintColor = StyleProvider.Color.textSecondary
                }
            }
            .store(in: &cancellables)

        // Bind favorite state
        viewModel.isFavoritePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isFavorite in
                if let imageResolver = self?.imageResolver {
                    // Use imageResolver to get the favorite icon
                    self?.favoritesIconImageView.image = imageResolver.favoriteIcon(isFavorite: isFavorite)
                } else {
                    // Fallback to system image
                    let starSymbol = isFavorite ? "star.fill" : "star"
                    let configuration = UIImage.SymbolConfiguration(weight: .semibold)
                    self?.favoritesIconImageView.image = UIImage(
                        systemName: starSymbol,
                        withConfiguration: configuration)?
                        .withRenderingMode(.alwaysTemplate)
                }
                
                self?.favoritesIconImageView.tintColor = StyleProvider.Color.favorites
            }
            .store(in: &cancellables)

        // Bind match time
        viewModel.matchTimePublisher
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] matchTime in
                self?.matchTimeLabel.text = matchTime
                self?.matchTimeLabel.isHidden = matchTime == nil || matchTime?.isEmpty == true
            }
            .store(in: &cancellables)

        // Bind live state
        viewModel.isLivePublisher
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLive in
                self?.liveIndicatorView.isHidden = !isLive
            }
            .store(in: &cancellables)

    }


    @objc private func favoriteButtonTapped() {
        viewModel?.toggleFavorite()
    }
}

// MARK: - Factory Methods
extension MatchHeaderView {

    private static func createFavoritesIconImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        let configuration = UIImage.SymbolConfiguration(weight: .semibold)
        imageView.image = UIImage(systemName: "star", withConfiguration: configuration)?.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = StyleProvider.Color.favorites
        return imageView
    }

    private static func createSportTypeImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(systemName: "soccerball")
        imageView.tintColor = StyleProvider.Color.textSecondary
        return imageView
    }

    private static func createLocationFlagImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.borderWidth = 0.5
        imageView.layer.borderColor = UIColor(red: 0.145, green: 0.149, blue: 0.204, alpha: 1).cgColor
        imageView.layer.masksToBounds = true
        imageView.image = UIImage(systemName: "globe")
        imageView.tintColor = StyleProvider.Color.textSecondary
        return imageView
    }

    private static func createCompetitionNameLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .medium, size: 11)
        label.numberOfLines = 1
        return label
    }

    private static func createFavoritesButton() -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        return button
    }

    private static func createMatchTimeLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .bold, size: 10)
        label.numberOfLines = 1
        label.textAlignment = .right
        return label
    }

    private static func createLeftContentStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 4 // Reduced spacing for better design match
        stackView.alignment = .center
        return stackView
    }

    private static func createRightContentStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 6
        stackView.alignment = .center
        return stackView
    }

    private static func createMainContentStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .center
        return stackView
    }

    private static func createLiveIndicatorView() -> UIView {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = StyleProvider.Color.primaryColor
        containerView.isHidden = true // Hidden by default

        // Calculate pill shape corner radius based on height
        let liveIndicatorHeight: CGFloat = 17 // 3 + 14 + 3 (padding + content + padding)
        containerView.layer.cornerRadius = liveIndicatorHeight / 2

        // Create the stack view for content
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 4
        stackView.alignment = .center

        // Create "LIVE" label
        let liveLabel = UILabel()
        liveLabel.text = "LIVE"
        liveLabel.font = StyleProvider.fontWith(type: .semibold, size: 10)
        liveLabel.textColor = .white

        // Create play icon
        let playIcon = UIImageView()
        playIcon.image = UIImage(systemName: "play.fill")?
            .withRenderingMode(.alwaysTemplate)
        playIcon.tintColor = .white
        playIcon.contentMode = .scaleAspectFit

        stackView.addArrangedSubview(liveLabel)
        stackView.addArrangedSubview(playIcon)

        containerView.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 6),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -6),
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 3),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -3),

            playIcon.widthAnchor.constraint(equalToConstant: 8),
            playIcon.heightAnchor.constraint(equalToConstant: 8),

            // Set explicit height for the container
            containerView.heightAnchor.constraint(equalToConstant: liveIndicatorHeight)
        ])

        return containerView
    }
}

// MARK: - Layout Setup
extension MatchHeaderView {

    private func setupSubviews() {
        // Add icons to left content stack view
        leftContentStackView.addArrangedSubview(favoritesIconImageView)
        leftContentStackView.addArrangedSubview(sportTypeImageView)
        leftContentStackView.addArrangedSubview(locationFlagImageView)
        leftContentStackView.addArrangedSubview(competitionNameLabel)

        // Add match time and live indicator to right content stack view
        rightContentStackView.addArrangedSubview(matchTimeLabel)
        rightContentStackView.addArrangedSubview(liveIndicatorView)

        // Add left content and right content to main stack view
        mainContentStackView.addArrangedSubview(leftContentStackView)
        mainContentStackView.addArrangedSubview(rightContentStackView)

        // Add main stack view to the view
        addSubview(mainContentStackView)
        addSubview(favoritesButton)

        favoritesButton.addTarget(self, action: #selector(favoriteButtonTapped), for: .touchUpInside)
    }

    private func setupConstraints() {
        // Set content priorities first
        competitionNameLabel.setContentHuggingPriority(UILayoutPriority(249), for: .horizontal)
        competitionNameLabel.setContentCompressionResistancePriority(UILayoutPriority(749), for: .horizontal)
        matchTimeLabel.setContentHuggingPriority(UILayoutPriority(251), for: .horizontal)
        matchTimeLabel.setContentCompressionResistancePriority(UILayoutPriority(751), for: .horizontal)

        NSLayoutConstraint.activate([
            // Height constraint for the view
            heightAnchor.constraint(equalToConstant: Self.height),

            // Main stack view - fills the entire view
            mainContentStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            mainContentStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            mainContentStackView.topAnchor.constraint(equalTo: topAnchor),
            mainContentStackView.bottomAnchor.constraint(equalTo: bottomAnchor),

            // Icon size constraints
            favoritesIconImageView.widthAnchor.constraint(equalToConstant: Self.height),
            favoritesIconImageView.heightAnchor.constraint(equalToConstant: Self.height),

            sportTypeImageView.widthAnchor.constraint(equalToConstant: Self.height),
            sportTypeImageView.heightAnchor.constraint(equalToConstant: Self.height),

            locationFlagImageView.widthAnchor.constraint(equalToConstant: Self.height),
            locationFlagImageView.heightAnchor.constraint(equalToConstant: Self.height),

            // Favorites button - invisible overlay for touch handling
            favoritesButton.centerXAnchor.constraint(equalTo: favoritesIconImageView.centerXAnchor),
            favoritesButton.centerYAnchor.constraint(equalTo: favoritesIconImageView.centerYAnchor),
            favoritesButton.widthAnchor.constraint(equalToConstant: Self.buttonTouchArea),
            favoritesButton.heightAnchor.constraint(equalToConstant: Self.buttonTouchArea),
        ])
    }
}

// MARK: - SwiftUI Previews
@available(iOS 17.0, *)
#Preview("MatchHeaderView - Examples") {
    ScrollView {
        VStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Standard Premier League")
                    .font(.caption)
                    .foregroundColor(.gray)

                MatchHeaderViewPreview {
                    let view = MatchHeaderView()
                    view.configure(with: MockMatchHeaderViewModel.premierLeagueHeader)
                    return view
                }
                .frame(width: 300, height: 17)
                .padding()
                .background(Color(StyleProvider.Color.backgroundColor))
                .cornerRadius(8)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("La Liga (Favorited)")
                    .font(.caption)
                    .foregroundColor(.gray)

                MatchHeaderViewPreview {
                    let view = MatchHeaderView()
                    view.configure(with: MockMatchHeaderViewModel.laLigaFavoriteHeader)
                    return view
                }
                .frame(width: 300, height: 17)
                .padding()
                .background(Color(StyleProvider.Color.backgroundColor))
                .cornerRadius(8)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Serie A Basketball")
                    .font(.caption)
                    .foregroundColor(.gray)

                MatchHeaderViewPreview {
                    let view = MatchHeaderView()
                    view.configure(with: MockMatchHeaderViewModel.serieABasketballHeader)
                    return view
                }
                .frame(width: 300, height: 17)
                .padding()
                .background(Color(StyleProvider.Color.backgroundColor))
                .cornerRadius(8)
            }




            VStack(alignment: .leading, spacing: 8) {
                Text("Long Competition Name")
                    .font(.caption)
                    .foregroundColor(.gray)

                MatchHeaderViewPreview {
                    let view = MatchHeaderView()
                    view.configure(with: MockMatchHeaderViewModel.longNameHeader)
                    return view
                }
                .frame(width: 300, height: 17)
                .padding()
                .background(Color(StyleProvider.Color.backgroundColor))
                .cornerRadius(8)
            }
        }
        .padding()
    }
}

// Helper for UIView previews in SwiftUI
struct MatchHeaderViewPreview: UIViewRepresentable {
    let viewFactory: () -> UIView

    func makeUIView(context: Context) -> UIView {
        return viewFactory()
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        // No updates needed
    }
}
