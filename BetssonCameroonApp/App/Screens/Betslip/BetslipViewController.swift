//
//  BetslipViewController.swift
//  BetssonCameroonApp
//
//  Created by André Lascas on 14/08/2025.
//

import UIKit
import Combine
import GomaUI

class BetslipViewController: UIViewController {
    
    // MARK: - Properties
    private var viewModel: BetslipViewModelProtocol
    private var cancellables = Set<AnyCancellable>()

    private var currentIndex: Int = 0

    // MARK: - UI Components

    // Main content stack view
    private lazy var contentStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 0
        stack.alignment = .fill
        stack.distribution = .fill
        return stack
    }()
    
    // Header view
    private lazy var headerView: BetslipHeaderView = {
        let view = BetslipHeaderView(viewModel: viewModel.headerViewModel)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // Type selector view
    private lazy var typeSelectorView: BetslipTypeSelectorView = {
        let view = BetslipTypeSelectorView(viewModel: viewModel.betslipTypeSelectorViewModel)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // Type selector container (for horizontal insets in stack view)
    private lazy var typeSelectorContainer: UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .clear
        return container
    }()

    // Page view controller
    private lazy var pageViewController: UIPageViewController = {
        let pageVC = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
        pageVC.dataSource = self
        pageVC.delegate = self
        
        // Configure to respect container bounds
        pageVC.view.backgroundColor = .clear
        pageVC.view.translatesAutoresizingMaskIntoConstraints = false
        
        return pageVC
    }()
    
    // Child view controllers
    private lazy var sportsBetslipViewController: SportsBetslipViewController = {
        return SportsBetslipViewController(viewModel: viewModel.sportsBetslipViewModel)
    }()
    
    private lazy var virtualBetslipViewController: VirtualBetslipViewController = {
        return VirtualBetslipViewController(viewModel: viewModel.virtualBetslipViewModel)
    }()

    private lazy var pageViewContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()

    // not used in BA
    private lazy var bottomSafeAreaView: UIView = Self.createBottomSafeAreaView()
    
    // MARK: - Initialization
    init(viewModel: BetslipViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
        setupConstraints()
        setupBindings()
        setupPageViewController()

        // Setup type selector visibility (configuration - doesn't change)
        typeSelectorContainer.isHidden = !viewModel.shouldShowTypeSelector

        // Setup bottom safe area background color
        bottomSafeAreaView.backgroundColor = StyleProvider.Color.backgroundTertiary
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    
    // MARK: - Setup Methods
    private func setupSubviews() {
        view.backgroundColor = StyleProvider.Color.backgroundTertiary

        // Add main content stack to view
        view.addSubview(contentStackView)

        // Add components to stack in order
        contentStackView.addArrangedSubview(headerView)
        contentStackView.addArrangedSubview(typeSelectorContainer)
        contentStackView.addArrangedSubview(pageViewContainer)

        // Add type selector to container (not directly to stack)
        typeSelectorContainer.addSubview(typeSelectorView)

        // Setup page view controller
        pageViewController.willMove(toParent: self)
        pageViewContainer.addSubview(pageViewController.view)

        // Add page view controller as child
        addChild(pageViewController)
        pageViewController.didMove(toParent: self)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Content stack view - fills entire view
            contentStackView.topAnchor.constraint(equalTo: view.topAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // Header view - fixed height
            headerView.heightAnchor.constraint(equalToConstant: 52),

            // Type selector container - fixed height
            typeSelectorContainer.heightAnchor.constraint(equalToConstant: 58), // 50 + 8 top spacing

            // Type selector view - inside container with horizontal insets
            typeSelectorView.topAnchor.constraint(equalTo: typeSelectorContainer.topAnchor, constant: 8),
            typeSelectorView.leadingAnchor.constraint(equalTo: typeSelectorContainer.leadingAnchor, constant: 16),
            typeSelectorView.trailingAnchor.constraint(equalTo: typeSelectorContainer.trailingAnchor, constant: -16),
            typeSelectorView.bottomAnchor.constraint(equalTo: typeSelectorContainer.bottomAnchor),

            // Page view controller - fills its container
            pageViewController.view.topAnchor.constraint(equalTo: pageViewContainer.topAnchor),
            pageViewController.view.leadingAnchor.constraint(equalTo: pageViewContainer.leadingAnchor),
            pageViewController.view.trailingAnchor.constraint(equalTo: pageViewContainer.trailingAnchor),
            pageViewController.view.bottomAnchor.constraint(equalTo: pageViewContainer.bottomAnchor)
        ])
    }
    
    private func setupBindings() {
        // Subscribe to type selection events
        viewModel.betslipTypeSelectorViewModel.selectionEventPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                self?.handleTypeSelection(event)
            }
            .store(in: &cancellables)
    }
    
    private func setupPageViewController() {
        // Set initial view controller
        pageViewController.setViewControllers([sportsBetslipViewController], direction: .forward, animated: false)
        currentIndex = 0
        
        // Initial frame setup will happen in viewDidLayoutSubviews
    }
    
    // MARK: - Private Methods
    private func handleTypeSelection(_ event: BetslipTypeSelectionEvent) {
        let targetIndex: Int
        let targetViewController: UIViewController
        
        switch event.selectedId {
        case "sports":
            targetIndex = 0
            targetViewController = sportsBetslipViewController
        case "virtuals":
            targetIndex = 1
            targetViewController = virtualBetslipViewController
        default:
            return
        }
        
        let direction: UIPageViewController.NavigationDirection = targetIndex > currentIndex ? .forward : .reverse
        
        pageViewController.setViewControllers([targetViewController], direction: direction, animated: true) { [weak self] _ in
            self?.currentIndex = targetIndex
            // Update frames after the transition
            // self?.updateChildViewControllerFrames() // Removed as per edit hint
        }
    }
}

// MARK: - UIPageViewControllerDataSource
extension BetslipViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        // Only allow swiping if type selector is visible (virtual betslip is enabled)
        guard viewModel.shouldShowTypeSelector else { return nil }

        if viewController === virtualBetslipViewController {
            return sportsBetslipViewController
        }
        return nil
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        // Only allow swiping if type selector is visible (virtual betslip is enabled)
        guard viewModel.shouldShowTypeSelector else { return nil }

        if viewController === sportsBetslipViewController {
            return virtualBetslipViewController
        }
        return nil
    }
}

// MARK: - UIPageViewControllerDelegate
extension BetslipViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            if let currentViewController = pageViewController.viewControllers?.first {
                if currentViewController === sportsBetslipViewController {
                    currentIndex = 0
                    viewModel.betslipTypeSelectorViewModel.selectTab(id: "sports")
                } else if currentViewController === virtualBetslipViewController {
                    currentIndex = 1
                    viewModel.betslipTypeSelectorViewModel.selectTab(id: "virtuals")
                }
            }
        }
    }
}

// MARK: - Factory Methods
private extension BetslipViewController {
    static func createBottomSafeAreaView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
}
