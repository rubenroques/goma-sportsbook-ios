/// Enum representing different types of banners that can be displayed in TopBannerSliderView
public enum BannerType {
    /// Info/promotional banner with message and optional button
    case info(SingleButtonBannerViewModelProtocol)

    /// Casino game banner with message and optional button
    case casino(SingleButtonBannerViewModelProtocol)

    /// Match banner with team information and betting outcomes
    case match(MatchBannerViewModelProtocol)
}

// MARK: - Convenience Properties
extension BannerType {

    /// Unique identifier for the banner based on its type and content
    public var id: String {
        switch self {
        case .info(let viewModel):
            return "info_\(viewModel.currentDisplayState.bannerData.type)"
        case .casino(let viewModel):
            return "casino_\(viewModel.currentDisplayState.bannerData.type)"
        case .match(let viewModel):
            return "match_\(viewModel.currentMatchData.id)"
        }
    }

    /// Cell identifier for collection view registration
    public var cellIdentifier: String {
        switch self {
        case .info, .casino:
            return "SingleButtonBannerCell"
        case .match:
            return "MatchBannerCell"
        }
    }

    /// Whether this banner should be visible
    public var isVisible: Bool {
        switch self {
        case .info(let viewModel), .casino(let viewModel):
            return viewModel.currentDisplayState.bannerData.isVisible
        case .match(let viewModel):
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
