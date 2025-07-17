import UIKit
import Combine

public enum MarketGroupSelectorBackgroundStyle {
    case light
    case dark
}

public class MarketGroupSelectorTabView: UIView {

    // MARK: - Private Properties
    private var viewModel: MarketGroupSelectorTabViewModelProtocol
    private let imageResolver: MarketGroupTabImageResolver
    private let backgroundStyle: MarketGroupSelectorBackgroundStyle
    private var cancellables = Set<AnyCancellable>()
    private var tabItemViews: [String: MarketGroupTabItemView] = [:]
    private var tabItemViewModels: [String: MockMarketGroupTabItemViewModel] = [:]

    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    private let loadingIndicator = UIActivityIndicatorView(style: .medium)
    private let emptyStateLabel = UILabel()

    // MARK: - Layout Constants
    private struct Constants {
        static let horizontalPadding: CGFloat = 16.0
        static let verticalPadding: CGFloat = 8.0
        static let tabItemSpacing: CGFloat = 1.0
        static let cornerRadius: CGFloat = 8.0
        static let animationDuration: TimeInterval = 0.3
        static let minimumHeight: CGFloat = 42.0
        static let darkBackgroundHex = "#03061b"
    }

    // MARK: - Initialization
    public init(viewModel: MarketGroupSelectorTabViewModelProtocol,
                imageResolver: MarketGroupTabImageResolver = DefaultMarketGroupTabImageResolver(),
                backgroundStyle: MarketGroupSelectorBackgroundStyle = .light) {
        self.viewModel = viewModel
        self.imageResolver = imageResolver
        self.backgroundStyle = backgroundStyle
        super.init(frame: .zero)
        setupSubviews()
        setupConstraints()
        setupBindings()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup Methods
    private func setupSubviews() {
        self.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(scrollView)
        addSubview(loadingIndicator)
        addSubview(emptyStateLabel)
        scrollView.addSubview(stackView)

        // Scroll view setup
        let backgroundColor = backgroundColorForStyle()
        scrollView.backgroundColor = backgroundColor
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.contentInsetAdjustmentBehavior = .never

        // Stack view setup
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = Constants.tabItemSpacing
        stackView.alignment = .center
        stackView.distribution = .fill

        // Loading indicator setup
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.color = StyleProvider.Color.highlightPrimary

        // Empty state label setup
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyStateLabel.text = "No market groups available"
        emptyStateLabel.textColor = StyleProvider.Color.textSecondary
        emptyStateLabel.font = StyleProvider.fontWith(type: .regular, size: 14)
        emptyStateLabel.textAlignment = .center
        emptyStateLabel.isHidden = true

        // View styling
        self.backgroundColor = backgroundColor
        
        //
        scrollView.isHidden = false
        loadingIndicator.stopAnimating()
        emptyStateLabel.isHidden = true
        isUserInteractionEnabled = true
        alpha = 1.0
        
    }

    private func setupConstraints() {

        NSLayoutConstraint.activate([
            // Scroll view constraints
            scrollView.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),
            scrollView.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.minimumHeight),

            // Stack view constraints
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.heightAnchor.constraint(equalTo: scrollView.heightAnchor),

            // Loading indicator constraints
            loadingIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: centerYAnchor),

            // Empty state label constraints
            emptyStateLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            emptyStateLabel.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: Constants.horizontalPadding),
            emptyStateLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -Constants.horizontalPadding)
        ])
    }

    private func setupBindings() {
        // Market groups binding
        viewModel.marketGroupsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] marketGroups in
                self?.updateTabItems(marketGroups)
            }
            .store(in: &cancellables)

        // Selection state binding - efficiently update only affected items
        viewModel.selectedMarketGroupIdPublisher
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] selectedId in
                self?.updateSelectionState(selectedId: selectedId)
            }
            .store(in: &cancellables)

        // Selection event binding for analytics/logging
        viewModel.selectionEventPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] selectionEvent in
                self?.handleSelectionEvent(selectionEvent)
            }
            .store(in: &cancellables)
    }

    // MARK: - Tab Management
    private func updateTabItems(_ marketGroups: [MarketGroupTabItemData]) {
        // Check if we need a full rebuild or just state updates
        let existingIds = Set(tabItemViews.keys)
        let newIds = Set(marketGroups.map { $0.id })
        
        // If the tab IDs haven't changed, just update titles (not visual states)
        if existingIds == newIds && !tabItemViews.isEmpty {
            // Update titles only, visual state is handled by updateSelectionState
            for marketGroup in marketGroups {
                if let tabViewModel = tabItemViewModels[marketGroup.id] {
                    tabViewModel.updateTitle(marketGroup.title)
                }
            }
            return
        }
        
        // Full rebuild needed (tabs added/removed or initial load)
        // Remove existing tab views
        clearTabItems()

        // Create new tab item views (without visual state)
        for marketGroup in marketGroups {
            createTabItemView(for: marketGroup)
        }

        // Apply current selection state
        if let selectedId = viewModel.currentSelectedMarketGroupId {
            updateSelectionState(selectedId: selectedId)
            scrollToTabItem(id: selectedId, animated: false)
        }
    }
    
    // Efficiently update only the selection state without recreating items
    private func updateSelectionState(selectedId: String?) {

        // Update visual states for all items
        for (id, viewModel) in tabItemViewModels {
            if viewModel.currentVisualState == .selected && id != selectedId {
                viewModel.setVisualState(.idle)
            } else if id == selectedId && viewModel.currentVisualState != .selected {
                viewModel.setVisualState(.selected)
            }
        }
        
    }

    private func createTabItemView(for marketGroup: MarketGroupTabItemData) {
        // Create tab item with idle state initially (selection state managed separately)
        let tabItemData = MarketGroupTabItemData(
            id: marketGroup.id,
            title: marketGroup.title,
            visualState: .idle,  // Always start with idle, updateSelectionState will set correct state
            iconType: marketGroup.iconType,
            badgeCount: marketGroup.badgeCount
        )
        let tabViewModel = MockMarketGroupTabItemViewModel(tabItemData: tabItemData)
        let tabView = MarketGroupTabItemView(viewModel: tabViewModel, imageResolver: imageResolver)

        // Store references
        tabItemViews[marketGroup.id] = tabView
        tabItemViewModels[marketGroup.id] = tabViewModel

        // Add to stack view
        stackView.addArrangedSubview(tabView)

        // Setup tab selection handling
        tabViewModel.onTapPublisher
            .sink { [weak self] tappedId in
                self?.viewModel.selectMarketGroup(id: tappedId)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Background Style Helpers
    private func backgroundColorForStyle() -> UIColor {
        switch backgroundStyle {
        case .light:
            return StyleProvider.Color.backgroundPrimary
        case .dark:
            return UIColor(hexString: Constants.darkBackgroundHex) ?? UIColor.black
        }
    }

    private func clearTabItems() {
        // Remove all arranged subviews
        stackView.arrangedSubviews.forEach { view in
            stackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }

        // Clear references
        tabItemViews.removeAll()
        tabItemViewModels.removeAll()
    }


    // MARK: - Scrolling and Navigation
    private func scrollToTabItem(id: String, animated: Bool = true) {
        guard let tabView = tabItemViews[id] else { return }

        let targetRect = stackView.convert(tabView.frame, to: scrollView)
        scrollView.scrollRectToVisible(targetRect, animated: animated)
    }

    // MARK: - Event Handling
    private func handleSelectionEvent(_ event: MarketGroupSelectionEvent) {
        // Scroll to the newly selected tab
        scrollToTabItem(id: event.selectedId)

        // Add haptic feedback for selection changes
        let selectionFeedback = UISelectionFeedbackGenerator()
        selectionFeedback.selectionChanged()

        // Log or handle analytics here if needed
        debugPrint("Market group selected: \(event.selectedId)")
    }

}

// MARK: - Intrinsic Content Size
extension MarketGroupSelectorTabView {
    public override var intrinsicContentSize: CGSize {
        let stackSize = stackView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        return CGSize(
            width: UIView.noIntrinsicMetric,
            height: max(stackSize.height + (Constants.verticalPadding * 2), Constants.minimumHeight)
        )
    }
}

// MARK: - Public Interface
extension MarketGroupSelectorTabView {

    /// Configure the view with a new view model (follows GomaUI pattern)
    public func configure(with newViewModel: MarketGroupSelectorTabViewModelProtocol) {
        // Cancel existing bindings
        cancellables.removeAll()
        
        // Update view model reference
        viewModel = newViewModel
        
        // Re-establish bindings with new view model
        setupBindings()
        
        // Update UI to reflect new view model state
        updateTabItems(viewModel.currentMarketGroups)
        if let selectedId = viewModel.currentSelectedMarketGroupId {
            updateSelectionState(selectedId: selectedId)
            scrollToTabItem(id: selectedId, animated: false)
        }
    }

    /// Scrolls to a specific tab item
    public func scrollToTab(id: String, animated: Bool = true) {
        scrollToTabItem(id: id, animated: animated)
    }

    /// Gets the current scroll position as a percentage (0.0 - 1.0)
    public var scrollProgress: CGFloat {
        let contentWidth = scrollView.contentSize.width
        let frameWidth = scrollView.frame.width

        guard contentWidth > frameWidth else { return 0.0 }

        let scrollableWidth = contentWidth - frameWidth
        return scrollView.contentOffset.x / scrollableWidth
    }
}

// MARK: - Preview Provider
#if DEBUG
import SwiftUI

@available(iOS 17.0, *)
#Preview("Standard Sports Markets") {
    PreviewUIViewController {
        let vc = UIViewController()
        let tabsView = MarketGroupSelectorTabView(viewModel: MockMarketGroupSelectorTabViewModel.standardSportsMarkets)
        tabsView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(tabsView)
        
        NSLayoutConstraint.activate([
            tabsView.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor, constant: 16),
            tabsView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor),
            tabsView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor)
        ])
        
        vc.view.backgroundColor = StyleProvider.Color.backgroundSecondary
        return vc
    }
}

@available(iOS 17.0, *)
#Preview("Mixed State Markets") {
    PreviewUIViewController {
        let vc = UIViewController()
        let tabsView = MarketGroupSelectorTabView(viewModel: MockMarketGroupSelectorTabViewModel.mixedStateMarkets)
        tabsView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(tabsView)
        
        NSLayoutConstraint.activate([
            tabsView.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor, constant: 16),
            tabsView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor),
            tabsView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor)
        ])
        
        vc.view.backgroundColor = StyleProvider.Color.backgroundSecondary
        return vc
    }
}

@available(iOS 17.0, *)
#Preview("Limited Markets") {
    PreviewUIViewController {
        let vc = UIViewController()
        let tabsView = MarketGroupSelectorTabView(viewModel: MockMarketGroupSelectorTabViewModel.limitedMarkets)
        tabsView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(tabsView)
        
        NSLayoutConstraint.activate([
            tabsView.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor, constant: 16),
            tabsView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor),
            tabsView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor)
        ])
        
        vc.view.backgroundColor = StyleProvider.Color.backgroundSecondary
        return vc
    }
}

@available(iOS 17.0, *)
#Preview("Loading State") {
    PreviewUIViewController {
        let vc = UIViewController()
        let tabsView = MarketGroupSelectorTabView(viewModel: MockMarketGroupSelectorTabViewModel.loadingMarkets)
        tabsView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(tabsView)
        
        NSLayoutConstraint.activate([
            tabsView.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor, constant: 16),
            tabsView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor),
            tabsView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor)
        ])
        
        vc.view.backgroundColor = StyleProvider.Color.backgroundSecondary
        return vc
    }
}

@available(iOS 17.0, *)
#Preview("Empty State") {
    PreviewUIViewController {
        let vc = UIViewController()
        let tabsView = MarketGroupSelectorTabView(viewModel: MockMarketGroupSelectorTabViewModel.emptyMarkets)
        tabsView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(tabsView)
        
        NSLayoutConstraint.activate([
            tabsView.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor, constant: 16),
            tabsView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor),
            tabsView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor)
        ])
        
        vc.view.backgroundColor = StyleProvider.Color.backgroundSecondary
        return vc
    }
}

@available(iOS 17.0, *)
#Preview("Disabled Markets") {
    PreviewUIViewController {
        let vc = UIViewController()
        let tabsView = MarketGroupSelectorTabView(viewModel: MockMarketGroupSelectorTabViewModel.disabledMarkets)
        tabsView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(tabsView)
        
        NSLayoutConstraint.activate([
            tabsView.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor, constant: 16),
            tabsView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor),
            tabsView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor)
        ])
        
        vc.view.backgroundColor = StyleProvider.Color.backgroundSecondary
        return vc
    }
}

@available(iOS 17.0, *)
#Preview("Market Category Tabs - Light") {
    PreviewUIViewController {
        let vc = UIViewController()
        let tabsView = MarketGroupSelectorTabView(
            viewModel: MockMarketGroupSelectorTabViewModel.marketCategoryTabs,
            backgroundStyle: .light
        )
        tabsView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(tabsView)
        
        NSLayoutConstraint.activate([
            tabsView.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor, constant: 16),
            tabsView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor),
            tabsView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor)
        ])
        
        vc.view.backgroundColor = StyleProvider.Color.backgroundSecondary
        return vc
    }
}

@available(iOS 17.0, *)
#Preview("Market Category Tabs - Dark") {
    PreviewUIViewController {
        let vc = UIViewController()
        let tabsView = MarketGroupSelectorTabView(
            viewModel: MockMarketGroupSelectorTabViewModel.marketCategoryTabs,
            backgroundStyle: .dark
        )
        tabsView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(tabsView)
        
        NSLayoutConstraint.activate([
            tabsView.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor, constant: 16),
            tabsView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor),
            tabsView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor)
        ])
        
        vc.view.backgroundColor = UIColor.black
        return vc
    }
}

#endif
