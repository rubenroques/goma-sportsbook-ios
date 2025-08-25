import Foundation
import UIKit
import Combine
import SwiftUI

/// A component for displaying a single row in a bet summary with title and value
public final class BetSummaryRowView: UIView {
    
    // MARK: - Properties
    public let viewModel: BetSummaryRowViewModelProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Components
    
    // Title label
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .semibold, size: 10)
        label.textColor = StyleProvider.Color.textPrimary
        return label
    }()
    
    // Value label
    private lazy var valueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .bold, size: 12)
        label.textColor = StyleProvider.Color.textPrimary
        label.textAlignment = .right
        return label
    }()
    
    // MARK: - Initialization
    public init(viewModel: BetSummaryRowViewModelProtocol) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupSubviews()
        setupConstraints()
        setupBindings()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupSubviews() {
        addSubview(titleLabel)
        addSubview(valueLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            valueLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            valueLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            valueLabel.leadingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor, constant: 8)
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
    
    // MARK: - Rendering
    private func render(data: BetSummaryRowData) {
        titleLabel.text = data.title
        valueLabel.text = data.value
        
        // Update enabled state
        isUserInteractionEnabled = data.isEnabled
        alpha = data.isEnabled ? 1.0 : 0.5
    }
}

// MARK: - SwiftUI Preview
#if DEBUG

@available(iOS 17.0, *)
#Preview("Potential Winnings") {
    PreviewUIView {
        BetSummaryRowView(viewModel: MockBetSummaryRowViewModel.potentialWinningsMock())
    }
    .frame(height: 30)
    .padding()
}

@available(iOS 17.0, *)
#Preview("Win Bonus") {
    PreviewUIView {
        BetSummaryRowView(viewModel: MockBetSummaryRowViewModel.winBonusMock())
    }
    .frame(height: 30)
    .padding()
}

@available(iOS 17.0, *)
#Preview("Payout") {
    PreviewUIView {
        BetSummaryRowView(viewModel: MockBetSummaryRowViewModel.payoutMock())
    }
    .frame(height: 30)
    .padding()
}

@available(iOS 17.0, *)
#Preview("Disabled") {
    PreviewUIView {
        BetSummaryRowView(viewModel: MockBetSummaryRowViewModel.disabledMock())
    }
    .frame(height: 30)
    .padding()
}

#endif 