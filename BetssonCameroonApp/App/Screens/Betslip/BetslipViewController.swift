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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    
    // MARK: - Setup Methods
    private func setupSubviews() {
        view.backgroundColor = StyleProvider.Color.backgroundTertiary
        
        view.addSubview(headerView)
        view.addSubview(typeSelectorView)
        view.addSubview(pageViewController.view)
        
        // Add page view controller as child
        addChild(pageViewController)
        pageViewController.didMove(toParent: self)
        
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Header view
            headerView.topAnchor.constraint(equalTo: view.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 52),
            
            // Type selector view
            typeSelectorView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 8),
            typeSelectorView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            typeSelectorView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            typeSelectorView.heightAnchor.constraint(equalToConstant: 50),
            
            // Page view controller
            pageViewController.view.topAnchor.constraint(equalTo: typeSelectorView.bottomAnchor),
            pageViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pageViewController.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
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
