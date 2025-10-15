import UIKit
import Combine

// MARK: - Display Models
public struct SuggestedBetsSectionState: Equatable {
    public let title: String
    public let isExpanded: Bool
    public let currentPageIndex: Int
    public let totalPages: Int
    public let isVisible: Bool

    public init(title: String,
                isExpanded: Bool,
                currentPageIndex: Int,
                totalPages: Int,
                isVisible: Bool = true) {
        self.title = title
        self.isExpanded = isExpanded
        self.currentPageIndex = currentPageIndex
        self.totalPages = totalPages
        self.isVisible = isVisible
    }
}

// MARK: - View Model Protocol
public protocol SuggestedBetsExpandedViewModelProtocol: AnyObject {
    // Header and state
    var displayStatePublisher: AnyPublisher<SuggestedBetsSectionState, Never> { get }

    // Child match card view models
    var matchCardViewModelsPublisher: AnyPublisher<[TallOddsMatchCardViewModelProtocol], Never> { get }
    var matchCardViewModels: [TallOddsMatchCardViewModelProtocol] { get }

    // Selected outcomes coming from the betslip (for selection sync in cells)
    var selectedOutcomeIdsPublisher: AnyPublisher<Set<String>, Never> { get }
    var selectedOutcomeIds: Set<String> { get }

    // Actions
    func toggleExpanded()
    func didScrollToPage(_ index: Int)
}


