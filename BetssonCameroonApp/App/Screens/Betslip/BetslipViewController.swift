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
    
    // MARK: - UI Components
    
    // Container view
    private lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = StyleProvider.Color.backgroundTertiary
        return view
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
    
    // Page view controller
    private lazy var pageViewController: UIPageViewController = {
        let pageVC = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
        pageVC.dataSource = self
        pageVC.delegate = self
        return pageVC
    }()
    
    // Child view controllers
    private lazy var sportsBetslipViewController: SportsBetslipViewController = {
        return SportsBetslipViewController(viewModel: viewModel)
    }()
    
    private lazy var virtualBetslipViewController: VirtualBetslipViewController = {
        return VirtualBetslipViewController(viewModel: viewModel)
    }()
    
    private var currentIndex: Int = 0
    
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
    }
    
    // MARK: - Setup Methods
    private func setupSubviews() {
        view.addSubview(containerView)
        
        containerView.addSubview(headerView)
        containerView.addSubview(typeSelectorView)
        containerView.addSubview(pageViewController.view)
        
        // Add page view controller as child
        addChild(pageViewController)
        pageViewController.didMove(toParent: self)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Container view
            containerView.topAnchor.constraint(equalTo: view.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Header view
            headerView.topAnchor.constraint(equalTo: containerView.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 52),
            
            // Type selector view
            typeSelectorView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 8),
            typeSelectorView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            typeSelectorView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            typeSelectorView.heightAnchor.constraint(equalToConstant: 50),
            
            // Page view controller
            pageViewController.view.topAnchor.constraint(equalTo: typeSelectorView.bottomAnchor),
            pageViewController.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            pageViewController.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            pageViewController.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
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
        
        // Setup header callbacks
        viewModel.headerViewModel.onCloseTapped = { [weak self] in
            self?.handleHeaderCloseTapped()
        }
        
        viewModel.headerViewModel.onJoinNowTapped = { [weak self] in
            self?.handleHeaderJoinNowTapped()
        }
        
        viewModel.headerViewModel.onLogInTapped = { [weak self] in
            self?.handleHeaderLogInTapped()
        }
    }
    
    private func setupPageViewController() {
        // Set initial view controller
        pageViewController.setViewControllers([sportsBetslipViewController], direction: .forward, animated: false)
        currentIndex = 0
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
        }
    }
    
    private func handleHeaderCloseTapped() {
        // TODO: Implement close action
        print("Header close button tapped")
    }
    
    private func handleHeaderJoinNowTapped() {
        // TODO: Implement join now action
        print("Header join now button tapped")
    }
    
    private func handleHeaderLogInTapped() {
        // TODO: Implement log in action
        print("Header log in button tapped")
    }
}

// MARK: - UIPageViewControllerDataSource
extension BetslipViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if viewController === virtualBetslipViewController {
            return sportsBetslipViewController
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
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
