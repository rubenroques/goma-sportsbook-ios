import UIKit
import Combine

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
    
    // Top card - Bet placement info
    private let betPlacedCardView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = StyleProvider.Color.backgroundTertiary
        view.layer.cornerRadius = 8
        return view
    }()
    
    private let betPlacedLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .regular, size: 14)
        label.textColor = StyleProvider.Color.textPrimary
        label.textAlignment = .center
        return label
    }()
    
    // Middle card - Match details
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
        stackView.addArrangedSubview(betPlacedCardView)
        stackView.addArrangedSubview(matchDetailsCardView)
        stackView.addArrangedSubview(resultCardView)
        
        // Setup top card
        betPlacedCardView.addSubview(betPlacedLabel)
        
        // Setup middle card
        matchDetailsCardView.addSubview(matchDetailsLabel)
        matchDetailsCardView.addSubview(betTypeLabel)
        
        // Setup bottom card
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
            
            // Top card constraints
            betPlacedCardView.heightAnchor.constraint(equalToConstant: 48),
            betPlacedLabel.leadingAnchor.constraint(equalTo: betPlacedCardView.leadingAnchor, constant: 16),
            betPlacedLabel.trailingAnchor.constraint(equalTo: betPlacedCardView.trailingAnchor, constant: -16),
            betPlacedLabel.centerYAnchor.constraint(equalTo: betPlacedCardView.centerYAnchor),
            
            // Middle card constraints
            matchDetailsCardView.heightAnchor.constraint(greaterThanOrEqualToConstant: 48),
            matchDetailsLabel.leadingAnchor.constraint(equalTo: matchDetailsCardView.leadingAnchor, constant: 16),
            matchDetailsLabel.trailingAnchor.constraint(equalTo: matchDetailsCardView.trailingAnchor, constant: -16),
            matchDetailsLabel.topAnchor.constraint(equalTo: matchDetailsCardView.topAnchor, constant: 12),
            
            betTypeLabel.leadingAnchor.constraint(equalTo: matchDetailsCardView.leadingAnchor, constant: 16),
            betTypeLabel.trailingAnchor.constraint(equalTo: matchDetailsCardView.trailingAnchor, constant: -16),
            betTypeLabel.topAnchor.constraint(equalTo: matchDetailsLabel.bottomAnchor, constant: 4),
            betTypeLabel.bottomAnchor.constraint(equalTo: matchDetailsCardView.bottomAnchor, constant: -12),
            
            // Bottom card constraints
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
        // Update top card
        betPlacedLabel.text = data.betPlacedDate
        
        // Update middle card
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
        }
    }
}

// MARK: - SwiftUI Preview
#if canImport(SwiftUI) && DEBUG
import SwiftUI

@available(iOS 13.0, *)
struct BetDetailResultSummaryPreviewView: UIViewRepresentable {
    private let viewModel: BetDetailResultSummaryViewModelProtocol
    
    init(viewModel: BetDetailResultSummaryViewModelProtocol) {
        self.viewModel = viewModel
    }
    
    func makeUIView(context: Context) -> BetDetailResultSummaryView {
        let view = BetDetailResultSummaryView(viewModel: viewModel)
        return view
    }
    
    func updateUIView(_ uiView: BetDetailResultSummaryView, context: Context) {
        // Updates handled by Combine binding
    }
}

@available(iOS 13.0, *)
struct BetDetailResultSummaryView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Lost state (matching the image)
            BetDetailResultSummaryPreviewView(
                viewModel: MockBetDetailResultSummaryViewModel.lostMock()
            )
            .frame(height: 200)
            .padding()
            .background(Color.white.opacity(0.1))
            .previewDisplayName("Lost State")
            
            // Won state
            BetDetailResultSummaryPreviewView(
                viewModel: MockBetDetailResultSummaryViewModel.wonMock()
            )
            .frame(height: 200)
            .padding()
            .background(Color.white.opacity(0.1))
            .previewDisplayName("Won State")
            
            // Draw state
            BetDetailResultSummaryPreviewView(
                viewModel: MockBetDetailResultSummaryViewModel.drawMock()
            )
            .frame(height: 200)
            .padding()
            .background(Color.white.opacity(0.1))
            .previewDisplayName("Draw State")
        }
    }
}
#endif
