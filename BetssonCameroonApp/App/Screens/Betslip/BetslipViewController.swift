import Foundation
import UIKit
import Combine
import GomaUI

/// A view controller for the betslip screen with header and bet submission
public final class BetslipViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: BetslipViewModelProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Components
    
    // Container view
    private lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = StyleProvider.Color.backgroundPrimary
        return view
    }()
    
    // Header view
    private lazy var headerView: BetslipHeaderView = {
        let headerView = BetslipHeaderView(viewModel: viewModel.headerViewModel)
        headerView.translatesAutoresizingMaskIntoConstraints = false
        return headerView
    }()
    
    // Bet info submission view
    private lazy var betInfoSubmissionView: BetInfoSubmissionView = {
        let betInfoView = BetInfoSubmissionView(viewModel: viewModel.betInfoSubmissionViewModel)
        betInfoView.translatesAutoresizingMaskIntoConstraints = false
        return betInfoView
    }()
    
    // MARK: - Initialization
    public init(viewModel: BetslipViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
        setupConstraints()
        setupBindings()
        setupActions()
    }
    
    // MARK: - Setup
    private func setupSubviews() {
        view.backgroundColor = StyleProvider.Color.backgroundPrimary
        
        view.addSubview(containerView)
        containerView.addSubview(headerView)
        containerView.addSubview(betInfoSubmissionView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Container
            containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            // Header view
            headerView.topAnchor.constraint(equalTo: containerView.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            
            // Bet info submission view
            betInfoSubmissionView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            betInfoSubmissionView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            betInfoSubmissionView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            betInfoSubmissionView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
    }
    
    private func setupBindings() {
        viewModel.dataPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] data in
                self?.render(data: data)
            }
            .store(in: &cancellables)
    }
    
    private func setupActions() {
        // Header actions
        viewModel.headerViewModel.onCloseTapped = { [weak self] in
            self?.viewModel.onHeaderCloseTapped()
        }
        
        viewModel.headerViewModel.onJoinNowTapped = { [weak self] in
            self?.viewModel.onHeaderJoinNowTapped()
        }
        
        viewModel.headerViewModel.onLogInTapped = { [weak self] in
            self?.viewModel.onHeaderLogInTapped()
        }
        
        // Bet info submission actions
        viewModel.betInfoSubmissionViewModel.onPlaceBetTapped = { [weak self] in
            self?.viewModel.onPlaceBetTapped()
        }
    }
    
    // MARK: - Rendering
    private func render(data: BetslipData) {
        // Update view state based on data
        view.isUserInteractionEnabled = data.isEnabled
        alpha = data.isEnabled ? 1.0 : 0.5
        
        // The child view models are already updated by the screen view model
        // No need to manually update them here
    }
} 
