/// Enum representing different types of banners that can be displayed in TopBannerSliderView
public enum BannerType {
    /// Single button banner with message and optional button
    case singleButton(SingleButtonBannerViewModelProtocol)

    /// Match banner with team information and betting outcomes
    case matchBanner(MatchBannerViewModelProtocol)
}

// MARK: - Convenience Properties
extension BannerType {

    /// Unique identifier for the banner based on its type and content
    public var id: String {
        switch self {
        case .singleButton(let viewModel):
            return "single_\(viewModel.currentDisplayState.bannerData.type)"
        case .matchBanner(let viewModel):
            return "match_\(viewModel.currentMatchData.id)"
        }
    }

    /// Cell identifier for collection view registration
    public var cellIdentifier: String {
        switch self {
        case .singleButton:
            return "SingleButtonBannerCell"
        case .matchBanner:
            return "MatchBannerCell"
        }
    }

    /// Whether this banner should be visible
    public var isVisible: Bool {
        switch self {
        case .singleButton(let viewModel):
            return viewModel.currentDisplayState.bannerData.isVisible
        case .matchBanner(let viewModel):
            return !viewModel.currentMatchData.id.isEmpty
        }
    }
}

// MARK: - Equatable
extension BannerType: Equatable {
    public static func == (lhs: BannerType, rhs: BannerType) -> Bool {
        return lhs.id == rhs.id
    }
}