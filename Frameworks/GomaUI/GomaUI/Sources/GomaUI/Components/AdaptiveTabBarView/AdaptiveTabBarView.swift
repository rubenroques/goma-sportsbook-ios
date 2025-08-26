//
//  AdaptiveTabBarView.swift
//  Sportsbook
//
//  Created by Ruben Roques on 16/05/2025.
//

import UIKit
import Combine
import SwiftUI

// MARK: - Animation Types
public enum TabBarAnimationType {
    case horizontalFlip
    case verticalCube
    case slideLeftToRight
    case modernMorphSlide
    case none
}

// MARK: - Background Mode
public enum TabBarBackgroundMode {
    case solid
    case blur
    case transparent
}

// MARK: - Slide Direction
private enum SlideDirection {
    case leftToRight  // Forward navigation
    case rightToLeft  // Back navigation
}

final public class AdaptiveTabBarView: UIView {
    // MARK: - Private Properties
    private var stackViewMap: [TabBarIdentifier: UIStackView] = [:]
    private var tabBarHistory: [TabBarIdentifier] = [] // Track navigation history
    private var currentActiveTabBarID: TabBarIdentifier?
    private var blurEffectView: UIVisualEffectView?

    private let viewModel: AdaptiveTabBarViewModelProtocol
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Public Properties
    public var onTabSelected: ((TabItem) -> Void) = { _ in }
    public var animationType: TabBarAnimationType = .slideLeftToRight
    public var backgroundMode: TabBarBackgroundMode = .solid {
        didSet {
            updateBackgroundMode()
        }
    }

    // MARK: - Initialization
    public init(viewModel: AdaptiveTabBarViewModelProtocol) {
        self.viewModel = viewModel
        super.init(frame: .zero)

        self.translatesAutoresizingMaskIntoConstraints = false

        setupSubviews()
        setupBindings()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private Methods
    private func setupBindings() {
        viewModel.displayStatePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] displayState in
                self?.render(state: displayState)
            }
            .store(in: &self.cancellables)
    }

    private func render(state: AdaptiveTabBarDisplayState) {
        // Store the previous active tab bar ID for animation
        let previousActiveTabBarID = stackViewMap.keys.first { stackView in
            stackViewMap[stackView]?.isHidden == false
        }

        // 1. Synchronize TabBar StackViews
        let incomingTabBarIDs = Set(state.tabBars.map { $0.id })
        let currentTabBarIDs = Set(stackViewMap.keys)

        // Remove old stack views
        for idToRemove in currentTabBarIDs.subtracting(incomingTabBarIDs) {
            stackViewMap[idToRemove]?.removeFromSuperview()
            stackViewMap.removeValue(forKey: idToRemove)
        }

        // Add/Update stack views
        for tabBarDisplayData in state.tabBars {
            let stackView: UIStackView
            if let existingStackView = stackViewMap[tabBarDisplayData.id] {
                stackView = existingStackView
            } else {
                stackView = Self.createStackView()
                stackViewMap[tabBarDisplayData.id] = stackView
                addStackViewBar(stackView) // Adds to hierarchy and sets constraints
            }

            // 2. Render TabItemViews within this stackView
            // Remove all current items from stack view before adding new/updated ones
            stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

            for itemDisplayData in tabBarDisplayData.items {
                let itemView = AdaptiveTabBarItemView() // Create new item view
                itemView.configure(with: itemDisplayData)

                itemView.onTap = { [weak self] in
                    guard let self = self else { return }
                    self.viewModel.selectTab(itemID: itemDisplayData.identifier, inTabBarID: tabBarDisplayData.id)

                    // For onTabSelected callback: Reconstruct a minimal TabItem or adjust callback signature.
                    // This requires TabItem or its key fields to be available. For now, construct from displayData.
                    let originalTabItem = TabItem(
                        identifier: itemDisplayData.identifier,
                        title: itemDisplayData.title,
                        icon: itemDisplayData.icon,
                        switchToTabBar: itemDisplayData.switchToTabBar
                    )
                    self.onTabSelected(originalTabItem)
                }
                stackView.addArrangedSubview(itemView)
            }
        }

        // 3. Update navigation history and animate tab bar switch
        updateNavigationHistory(newActiveTabBarID: state.activeTabBarID)
        animateTabBarSwitch(
            from: previousActiveTabBarID,
            to: state.activeTabBarID
        )
        }

    // MARK: - Navigation History Methods
    private func updateNavigationHistory(newActiveTabBarID: TabBarIdentifier) {
        // Only update if it's actually changing
        guard currentActiveTabBarID != newActiveTabBarID else { return }

        // Add current tab bar to history if it exists
        if let currentID = currentActiveTabBarID {
            // Remove if already in history to avoid duplicates
            tabBarHistory.removeAll { $0 == currentID }
            // Add to end of history
            tabBarHistory.append(currentID)

            // Keep history manageable (last 10 items)
            if tabBarHistory.count > 10 {
                tabBarHistory.removeFirst()
            }
        }

        currentActiveTabBarID = newActiveTabBarID
    }

    private func getSlideDirection(from previousTabBarID: TabBarIdentifier?, to newTabBarID: TabBarIdentifier) -> SlideDirection {
        guard let previousTabBarID = previousTabBarID else { return .leftToRight }

        // Check if we're going back to a previous tab bar
        if let lastIndex = tabBarHistory.lastIndex(of: newTabBarID) {
            // We're going back - remove this tab and all tabs after it from history
            // This simulates "popping" the navigation stack back to this point
            tabBarHistory.removeSubrange(lastIndex...)
            return .rightToLeft
        } else {
            // We're going forward - slide left to right
            return .leftToRight
        }
    }

        // MARK: - Animation Methods
    private func animateTabBarSwitch(from previousTabBarID: TabBarIdentifier?, to newTabBarID: TabBarIdentifier) {
        guard let previousTabBarID = previousTabBarID,
              previousTabBarID != newTabBarID,
              let previousStackView = stackViewMap[previousTabBarID],
              let newStackView = stackViewMap[newTabBarID] else {
            // No animation needed, just show/hide directly
            for (id, stackView) in stackViewMap {
                stackView.isHidden = (id != newTabBarID)
            }
            return
        }

        switch animationType {
        case .horizontalFlip:
            animateHorizontalFlip(from: previousStackView, to: newStackView, newTabBarID: newTabBarID)
        case .verticalCube:
            animateVerticalCube(from: previousStackView, to: newStackView, newTabBarID: newTabBarID)
        case .slideLeftToRight:
            let direction = getSlideDirection(from: previousTabBarID, to: newTabBarID)
            animateSlideWithDirection(from: previousStackView, to: newStackView, direction: direction, newTabBarID: newTabBarID)
        case .modernMorphSlide:
            animateModernMorphSlide(from: previousStackView, to: newStackView, newTabBarID: newTabBarID)
        case .none:
            // Instant switch
            for (id, stackView) in stackViewMap {
                stackView.isHidden = (id != newTabBarID)
            }
        }
    }

    private func animateHorizontalFlip(from previousStackView: UIStackView, to newStackView: UIStackView, newTabBarID: TabBarIdentifier) {
        // Prepare for animation
        newStackView.isHidden = false
        newStackView.alpha = 0

        // Set up 3D transform for flip animation
        let duration: TimeInterval = 0.6
        let perspective: CGFloat = -1.0 / 1000.0

        // Create 3D transform for the flip
        var transform3D = CATransform3DIdentity
        transform3D.m34 = perspective

        // First half: Flip out the current tab bar
        UIView.animate(withDuration: duration / 2, delay: 0, options: [.curveEaseIn], animations: {
            var flipOutTransform = transform3D
            flipOutTransform = CATransform3DRotate(flipOutTransform, .pi / 2, 0, 1, 0)
            previousStackView.layer.transform = flipOutTransform
            previousStackView.alpha = 0
        }) { _ in
            // Hide the previous stack view
            previousStackView.isHidden = true
            previousStackView.layer.transform = CATransform3DIdentity
            previousStackView.alpha = 1

            // Prepare new stack view for flip in
            var flipInStartTransform = transform3D
            flipInStartTransform = CATransform3DRotate(flipInStartTransform, -.pi / 2, 0, 1, 0)
            newStackView.layer.transform = flipInStartTransform
            newStackView.alpha = 0

            // Second half: Flip in the new tab bar
            UIView.animate(withDuration: duration / 2, delay: 0, options: [.curveEaseOut], animations: {
                newStackView.layer.transform = CATransform3DIdentity
                newStackView.alpha = 1
            }) { _ in
                // Ensure all other stack views are hidden
                for (id, stackView) in self.stackViewMap {
                    if id != newTabBarID {
                        stackView.isHidden = true
                    }
                }
            }
        }
    }

    private func animateVerticalCube(from previousStackView: UIStackView, to newStackView: UIStackView, newTabBarID: TabBarIdentifier) {
        // Prepare for animation
        newStackView.isHidden = false
        newStackView.alpha = 1

        // Set up 3D transform for cube animation
        let duration: TimeInterval = 0.8
        let perspective: CGFloat = -1.0 / 800.0
        let tabBarHeight = self.frame.height

        // Create 3D transform with perspective
        var transform3D = CATransform3DIdentity
        transform3D.m34 = perspective

        // Position the new stack view below (like the bottom face of a cube)
        var newStackViewStartTransform = transform3D
        newStackViewStartTransform = CATransform3DTranslate(newStackViewStartTransform, 0, tabBarHeight, 0)
        newStackViewStartTransform = CATransform3DRotate(newStackViewStartTransform, -.pi / 2, 1, 0, 0)
        newStackView.layer.transform = newStackViewStartTransform

        // Animate the cube rotation
        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: [.curveEaseInOut], animations: {
            // Rotate the previous stack view up (like top face of cube going away)
            var previousTransform = transform3D
            previousTransform = CATransform3DTranslate(previousTransform, 0, -tabBarHeight, 0)
            previousTransform = CATransform3DRotate(previousTransform, .pi / 2, 1, 0, 0)
            previousStackView.layer.transform = previousTransform

            // Rotate the new stack view into place
            newStackView.layer.transform = CATransform3DIdentity
            previousStackView.alpha = 0.0
        }) { _ in
            // Clean up
            previousStackView.isHidden = true
            previousStackView.layer.transform = CATransform3DIdentity

            // Ensure all other stack views are hidden
            for (id, stackView) in self.stackViewMap {
                if id != newTabBarID {
                    stackView.isHidden = true
                    stackView.layer.transform = CATransform3DIdentity
                }
            }
        }
    }

        private func animateSlideWithDirection(from previousStackView: UIStackView, to newStackView: UIStackView, direction: SlideDirection, newTabBarID: TabBarIdentifier) {
        // Prepare for animation
        newStackView.isHidden = false
        newStackView.alpha = 1

        let duration: TimeInterval = 0.9
        let tabBarWidth = self.frame.width

        // Set up transforms based on direction
        let (newStackStartX, previousStackEndX): (CGFloat, CGFloat)

        switch direction {
        case .leftToRight:
            // Forward navigation: new comes from right, previous goes left
            newStackStartX = tabBarWidth
            previousStackEndX = -tabBarWidth
        case .rightToLeft:
            // Back navigation: new comes from left, previous goes right
            newStackStartX = -tabBarWidth
            previousStackEndX = tabBarWidth
        }

        // Position the new stack view off-screen
        newStackView.transform = CGAffineTransform(translationX: newStackStartX, y: 0)

        // Animate both stack views simultaneously
        UIView.animate(
            withDuration: duration,
            delay: 0,
            usingSpringWithDamping: 0.9,  // Very subtle spring effect
            initialSpringVelocity: 0.3,   // Low velocity for gentle bounce
            options: [.curveEaseInOut],
            animations: {
                // Slide current tab bar off-screen in appropriate direction
                previousStackView.transform = CGAffineTransform(translationX: previousStackEndX, y: 0)

                // Slide new tab bar to center
                newStackView.transform = CGAffineTransform.identity
            }
        ) { _ in
            // Clean up
            previousStackView.isHidden = true
            previousStackView.transform = CGAffineTransform.identity

            // Ensure all other stack views are hidden and reset
            for (id, stackView) in self.stackViewMap {
                if id != newTabBarID {
                    stackView.isHidden = true
                    stackView.transform = CGAffineTransform.identity
                }
            }
        }
    }

    private func animateModernMorphSlide(from previousStackView: UIStackView, to newStackView: UIStackView, newTabBarID: TabBarIdentifier) {
        // Prepare for animation
        newStackView.isHidden = false
        newStackView.alpha = 1

        let duration: TimeInterval = 0.7
        let tabBarWidth = self.frame.width

        // Modern animation combines: slide + scale + blur + elastic spring

        // Position new stack view off-screen to the right with scale
        newStackView.transform = CGAffineTransform(translationX: tabBarWidth * 0.3, y: 0)
            .scaledBy(x: 0.8, y: 0.8)
        newStackView.alpha = 0

        // Add subtle blur effect during transition
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = self.bounds
        blurView.alpha = 0
        self.insertSubview(blurView, at: 0)

        // Phase 1: Blur in and start morphing (first 30% of animation)
        UIView.animate(withDuration: duration * 0.3, delay: 0, options: [.curveEaseOut], animations: {
            blurView.alpha = 0.3

            // Start morphing the previous stack view
            previousStackView.transform = CGAffineTransform(translationX: -tabBarWidth * 0.2, y: 0)
                .scaledBy(x: 1.1, y: 1.1)
            previousStackView.alpha = 0.7
        }) { _ in

            // Phase 2: Main transition with elastic spring (remaining 70%)
            UIView.animate(
                withDuration: duration * 0.7,
                delay: 0,
                usingSpringWithDamping: 0.75,  // More pronounced spring for modern feel
                initialSpringVelocity: 0.8,    // Higher velocity for dynamic effect
                options: [.curveEaseInOut],
                animations: {
                    // Complete the previous stack view exit
                    previousStackView.transform = CGAffineTransform(translationX: -tabBarWidth, y: 0)
                        .scaledBy(x: 0.9, y: 0.9)
                    previousStackView.alpha = 0

                    // Animate new stack view with elastic entrance
                    newStackView.transform = CGAffineTransform.identity
                    newStackView.alpha = 1

                    // Fade out blur
                    blurView.alpha = 0
                }
            ) { _ in
                // Clean up
                previousStackView.isHidden = true
                previousStackView.transform = CGAffineTransform.identity
                previousStackView.alpha = 1

                blurView.removeFromSuperview()

                // Ensure all other stack views are hidden and reset
                for (id, stackView) in self.stackViewMap {
                    if id != newTabBarID {
                        stackView.isHidden = true
                        stackView.transform = CGAffineTransform.identity
                        stackView.alpha = 1
                    }
                }
            }
        }
    }
}

// MARK: - Factory Methods
private extension AdaptiveTabBarView {
    static func createStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 4
        return stackView
    }
}

// MARK: - Constraints
private extension AdaptiveTabBarView {
    private func setupSubviews() {
        updateBackgroundMode()
        self.initConstraints()
    }

    private func updateBackgroundMode() {
        switch backgroundMode {
        case .solid:
            setupSolidBackground()
        case .blur:
            setupBlurBackground()
        case .transparent:
            setupTransparentBackground()
        }
    }

    private func setupSolidBackground() {
        // Remove blur effect if it exists
        blurEffectView?.removeFromSuperview()
        blurEffectView = nil

        // Set solid background
        self.backgroundColor = StyleProvider.Color.backgroundColor
    }

    private func setupBlurBackground() {
        // Clear solid background
        self.backgroundColor = .clear

        // Remove existing blur effect if any
        blurEffectView?.removeFromSuperview()

        // Create new blur effect - thinner options available:
        // .systemUltraThinMaterialLight (thinnest), .systemUltraThinMaterialDark, .systemUltraThinMaterial
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        let newBlurEffectView = UIVisualEffectView(effect: blurEffect)
        newBlurEffectView.translatesAutoresizingMaskIntoConstraints = false

        // Store reference and add to view
        blurEffectView = newBlurEffectView
        self.insertSubview(newBlurEffectView, at: 0)

        // Constrain blur view to fill the entire tab bar
        NSLayoutConstraint.activate([
            newBlurEffectView.leadingAnchor.constraint(equalTo: leadingAnchor),
            newBlurEffectView.trailingAnchor.constraint(equalTo: trailingAnchor),
            newBlurEffectView.topAnchor.constraint(equalTo: topAnchor),
            newBlurEffectView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    private func setupTransparentBackground() {
        // Remove blur effect if it exists
        blurEffectView?.removeFromSuperview()
        blurEffectView = nil
        
        // Set transparent background
        self.backgroundColor = .clear
    }

    private func initConstraints() {
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 52)
        ])
    }

    private func addStackViewBar(_ stackView: UIStackView) {
        self.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
}

// MARK: - Preview Provider
#if DEBUG

@available(iOS 17.0, *)
#Preview("Blur Background") {
    PreviewUIView {
        let tabBarView = AdaptiveTabBarView(viewModel: MockAdaptiveTabBarViewModel.defaultMock)
        tabBarView.backgroundMode = .blur
        return tabBarView
    }
    .frame(height: 52)
}

@available(iOS 17.0, *)
#Preview("Solid Background") {
    PreviewUIView {
        let tabBarView = AdaptiveTabBarView(viewModel: MockAdaptiveTabBarViewModel.defaultMock)
        tabBarView.backgroundMode = .solid
        return tabBarView
    }
    .frame(height: 52)
}

@available(iOS 17.0, *)
#Preview("Transparent Background") {
    PreviewUIView {
        let tabBarView = AdaptiveTabBarView(viewModel: MockAdaptiveTabBarViewModel.defaultMock)
        tabBarView.backgroundMode = .transparent
        return tabBarView
    }
    .frame(height: 52)
}

@available(iOS 17.0, *)
#Preview("Reversible Slide") {
    PreviewUIView {
        let tabBarView = AdaptiveTabBarView(viewModel: MockAdaptiveTabBarViewModel.defaultMock)
        tabBarView.animationType = .slideLeftToRight
        return tabBarView
    }
    .frame(height: 52)
}

@available(iOS 17.0, *)
#Preview("Vertical Cube Animation") {
    PreviewUIView {
        let tabBarView = AdaptiveTabBarView(viewModel: MockAdaptiveTabBarViewModel.defaultMock)
        tabBarView.animationType = .verticalCube
        return tabBarView
    }
    .frame(height: 52)
}

@available(iOS 17.0, *)
#Preview("No Animation") {
    PreviewUIView {
        let tabBarView = AdaptiveTabBarView(viewModel: MockAdaptiveTabBarViewModel.defaultMock)
        tabBarView.animationType = .none
        return tabBarView
    }
    .frame(height: 52)
}

#endif
