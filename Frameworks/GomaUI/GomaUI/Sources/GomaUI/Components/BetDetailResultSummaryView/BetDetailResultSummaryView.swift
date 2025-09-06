import UIKit
import Combine
import SwiftUI

public class BetDetailResultSummaryView: UIView {
    
    // MARK: - Properties
    private let viewModel: BetDetailResultSummaryViewModelProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Components
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = StyleProvider.Color.backgroundSecondary
        view.layer.cornerRadius = 8
        return view
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.distribution = .fill
        stackView.layer.cornerRadius = 8
        stackView.clipsToBounds = true
        return stackView
    }()
    
    // Top card - Match details
    private let matchDetailsCardView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = StyleProvider.Color.backgroundTertiary
        view.layer.cornerRadius = 8
        return view
    }()
    
    private let matchDetailsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .bold, size: 14)
        label.textColor = StyleProvider.Color.textPrimary
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let betTypeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .regular, size: 14)
        label.textColor = StyleProvider.Color.textPrimary
        label.textAlignment = .center
        return label
    }()
    
    // Bottom card - Result summary
    private let resultCardView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = StyleProvider.Color.backgroundTertiary
        view.layer.cornerRadius = 8
        return view
    }()
    
    private let resultLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .regular, size: 14)
        label.textColor = StyleProvider.Color.textPrimary
        label.text = "Result"
        return label
    }()
    
    private let resultPillView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 12
        return view
    }()
    
    private let resultPillLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .semibold, size: 12)
        label.textAlignment = .center
        return label
    }()
    
    // MARK: - Initialization
    public init(viewModel: BetDetailResultSummaryViewModelProtocol) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupView()
        setupConstraints()
        bindViewModel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupView() {
        addSubview(containerView)
        containerView.addSubview(stackView)
        
        // Add cards to stack view
        stackView.addArrangedSubview(matchDetailsCardView)
        stackView.addArrangedSubview(resultCardView)
        
        // Setup top card - match details
        matchDetailsCardView.addSubview(matchDetailsLabel)
        matchDetailsCardView.addSubview(betTypeLabel)
        
        // Setup bottom card - result
        resultCardView.addSubview(resultLabel)
        resultCardView.addSubview(resultPillView)
        resultPillView.addSubview(resultPillLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Container constraints
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // Stack view constraints with 8px padding
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8),
            
            // Top card constraints - match details
            matchDetailsCardView.heightAnchor.constraint(greaterThanOrEqualToConstant: 48),
            matchDetailsLabel.leadingAnchor.constraint(equalTo: matchDetailsCardView.leadingAnchor, constant: 16),
            matchDetailsLabel.trailingAnchor.constraint(equalTo: matchDetailsCardView.trailingAnchor, constant: -16),
            matchDetailsLabel.topAnchor.constraint(equalTo: matchDetailsCardView.topAnchor, constant: 12),
            
            betTypeLabel.leadingAnchor.constraint(equalTo: matchDetailsCardView.leadingAnchor, constant: 16),
            betTypeLabel.trailingAnchor.constraint(equalTo: matchDetailsCardView.trailingAnchor, constant: -16),
            betTypeLabel.topAnchor.constraint(equalTo: matchDetailsLabel.bottomAnchor, constant: 4),
            betTypeLabel.bottomAnchor.constraint(equalTo: matchDetailsCardView.bottomAnchor, constant: -12),
            
            // Bottom card constraints - result
            resultCardView.heightAnchor.constraint(equalToConstant: 48),
            resultLabel.leadingAnchor.constraint(equalTo: resultCardView.leadingAnchor, constant: 16),
            resultLabel.centerYAnchor.constraint(equalTo: resultCardView.centerYAnchor),
            
            resultPillView.trailingAnchor.constraint(equalTo: resultCardView.trailingAnchor, constant: -16),
            resultPillView.centerYAnchor.constraint(equalTo: resultCardView.centerYAnchor),
            resultPillView.heightAnchor.constraint(equalToConstant: 24),
            resultPillView.widthAnchor.constraint(equalToConstant: 60),
            
            resultPillLabel.topAnchor.constraint(equalTo: resultPillView.topAnchor),
            resultPillLabel.leadingAnchor.constraint(equalTo: resultPillView.leadingAnchor),
            resultPillLabel.trailingAnchor.constraint(equalTo: resultPillView.trailingAnchor),
            resultPillLabel.bottomAnchor.constraint(equalTo: resultPillView.bottomAnchor)
        ])
    }
    
    private func bindViewModel() {
        viewModel.dataPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] data in
                self?.updateUI(with: data)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - UI Updates
    private func updateUI(with data: BetDetailResultSummaryData) {
        // Update top card - match details
        matchDetailsLabel.text = data.matchDetails
        betTypeLabel.text = data.betType
        
        // Update bottom card (result pill)
        switch data.resultState {
        case .won:
            resultPillView.backgroundColor = StyleProvider.Color.alertSuccess
            resultPillLabel.textColor = StyleProvider.Color.allWhite
            resultPillLabel.text = "Won"
            
        case .lost:
            resultPillView.backgroundColor = StyleProvider.Color.backgroundGradient2
            resultPillLabel.textColor = StyleProvider.Color.alertError
            resultPillLabel.text = "Lost"
            
        case .draw:
            resultPillView.backgroundColor = StyleProvider.Color.alertWarning
            resultPillLabel.textColor = StyleProvider.Color.allWhite
            resultPillLabel.text = "Draw"
            
        case .open:
            resultPillView.backgroundColor = StyleProvider.Color.backgroundSecondary
            resultPillLabel.textColor = StyleProvider.Color.textSecondary
            resultPillLabel.text = "Pending"
        }
    }
}

// MARK: - SwiftUI Preview
#if DEBUG

@available(iOS 17.0, *)
#Preview("Bet Result Summary - Lost State") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = StyleProvider.Color.backgroundColor
        
        let resultSummaryView = BetDetailResultSummaryView(viewModel: MockBetDetailResultSummaryViewModel.lostMock())
        resultSummaryView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(resultSummaryView)
        
        NSLayoutConstraint.activate([
            resultSummaryView.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            resultSummaryView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor),
            resultSummaryView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            resultSummaryView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16)
        ])
        
        return vc
    }
}

@available(iOS 17.0, *)
#Preview("Bet Result Summary - Won State") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = StyleProvider.Color.backgroundColor
        
        let resultSummaryView = BetDetailResultSummaryView(viewModel: MockBetDetailResultSummaryViewModel.wonMock())
        resultSummaryView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(resultSummaryView)
        
        NSLayoutConstraint.activate([
            resultSummaryView.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            resultSummaryView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor),
            resultSummaryView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            resultSummaryView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16)
        ])
        
        return vc
    }
}

@available(iOS 17.0, *)
#Preview("Bet Result Summary - Draw State") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = StyleProvider.Color.backgroundColor
        
        let resultSummaryView = BetDetailResultSummaryView(viewModel: MockBetDetailResultSummaryViewModel.drawMock())
        resultSummaryView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(resultSummaryView)
        
        NSLayoutConstraint.activate([
            resultSummaryView.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            resultSummaryView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor),
            resultSummaryView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            resultSummaryView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16)
        ])
        
        return vc
    }
}

#endif
