import Foundation
import UIKit
import Combine
import SwiftUI

/// A component for submitting bets with bet summary, amount input, and place bet button
public final class BetInfoSubmissionView: UIView {
    
    // MARK: - Properties
    public let viewModel: BetInfoSubmissionViewModelProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Components
    
    // Container view
    private lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = StyleProvider.Color.backgroundSecondary
        view.layer.cornerRadius = 8
        return view
    }()
    
    // Bet summary section
    private lazy var betSummaryStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        return stackView
    }()
    
    // Potential winnings row
    private lazy var potentialWinningsRow: BetSummaryRowView = {
        return BetSummaryRowView(title: "POTENTIAL WINNINGS", value: "XAF 0.00")
    }()
    
    // Win bonus row
    private lazy var winBonusRow: BetSummaryRowView = {
        return BetSummaryRowView(title: "X% WIN BONUS", value: "-XAF 0.00")
    }()
    
    // Payout row
    private lazy var payoutRow: BetSummaryRowView = {
        return BetSummaryRowView(title: "PAYOUT", value: "XAF 0.00")
    }()
    
    // Amount text field
    private lazy var amountTextField: BorderedTextFieldView = {
        let textField = BorderedTextFieldView(viewModel: viewModel.amountTextFieldViewModel)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.onTextChanged = { [weak self] text in
            self?.viewModel.onAmountChanged(text)
        }
        return textField
    }()
    
    // Quick add buttons stack
    private lazy var quickAddStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 4
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    // Quick add buttons
    private lazy var quickAdd100Button: QuickAddButton = {
        return QuickAddButton(amount: 100) { [weak self] in
            self?.viewModel.onQuickAddTapped(100)
        }
    }()
    
    private lazy var quickAdd250Button: QuickAddButton = {
        return QuickAddButton(amount: 250) { [weak self] in
            self?.viewModel.onQuickAddTapped(250)
        }
    }()
    
    private lazy var quickAdd500Button: QuickAddButton = {
        return QuickAddButton(amount: 500) { [weak self] in
            self?.viewModel.onQuickAddTapped(500)
        }
    }()
    
    // Place bet button
    private lazy var placeBetButton: ButtonView = {
        let button = ButtonView(viewModel: viewModel.placeBetButtonViewModel)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.onButtonTapped = { [weak self] in
            self?.viewModel.onPlaceBetTapped()
        }
        return button
    }()
    
    // MARK: - Initialization
    public init(viewModel: BetInfoSubmissionViewModelProtocol) {
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
        addSubview(containerView)
        
        // Add bet summary section directly to container
        containerView.addSubview(betSummaryStackView)
        betSummaryStackView.addArrangedSubview(potentialWinningsRow)
        betSummaryStackView.addArrangedSubview(winBonusRow)
        betSummaryStackView.addArrangedSubview(payoutRow)
        
        // Add amount text field directly to container
        containerView.addSubview(amountTextField)
        
        // Add quick add buttons stack directly to container
        containerView.addSubview(quickAddStackView)
        quickAddStackView.addArrangedSubview(quickAdd100Button)
        quickAddStackView.addArrangedSubview(quickAdd250Button)
        quickAddStackView.addArrangedSubview(quickAdd500Button)
        
        // Add place bet button directly to container
        containerView.addSubview(placeBetButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Container
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // Bet summary stack view
            betSummaryStackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            betSummaryStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            betSummaryStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            // Amount text field
            amountTextField.topAnchor.constraint(equalTo: betSummaryStackView.bottomAnchor, constant: 16),
            amountTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            amountTextField.heightAnchor.constraint(equalToConstant: 52),
//            amountTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            // Quick add buttons stack
            quickAddStackView.leadingAnchor.constraint(equalTo: amountTextField.trailingAnchor, constant: 8),
            quickAddStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            quickAddStackView.heightAnchor.constraint(equalToConstant: 50),
            quickAddStackView.centerYAnchor.constraint(equalTo: amountTextField.centerYAnchor, constant: -2),
            
            // Quick add buttons equal width
            quickAdd100Button.widthAnchor.constraint(equalToConstant: 50),
            quickAdd250Button.widthAnchor.constraint(equalToConstant: 50),
            quickAdd500Button.widthAnchor.constraint(equalToConstant: 50),
            
            // Place bet button
            placeBetButton.topAnchor.constraint(equalTo: amountTextField.bottomAnchor, constant: 12),
            placeBetButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            placeBetButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            placeBetButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),
            placeBetButton.heightAnchor.constraint(equalToConstant: 50)
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
    private func render(data: BetInfoSubmissionData) {
        // Update bet summary
        potentialWinningsRow.updateValue(data.potentialWinnings)
        winBonusRow.updateValue(data.winBonus)
        payoutRow.updateValue(data.payout)
        
    }
}

// MARK: - BetSummaryRowView
private final class BetSummaryRowView: UIView {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .semibold, size: 10)
        label.textColor = StyleProvider.Color.textPrimary
        return label
    }()
    
    private let valueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .bold, size: 12)
        label.textColor = StyleProvider.Color.textPrimary
        label.textAlignment = .right
        return label
    }()
    
    init(title: String, value: String) {
        super.init(frame: .zero)
        setupSubviews()
        titleLabel.text = title
        valueLabel.text = value
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubviews() {
        addSubview(titleLabel)
        addSubview(valueLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            valueLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            valueLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            valueLabel.leadingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor, constant: 8)
        ])
    }
    
    func updateValue(_ value: String) {
        valueLabel.text = value
    }
}

// MARK: - QuickAddButton
private final class QuickAddButton: UIButton {
    private var action: (() -> Void)?
    
    init(amount: Int, action: @escaping () -> Void) {
        super.init(frame: .zero)
        self.action = action
        setupButton(amount: amount)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupButton(amount: Int) {
        setTitle("+\(amount)", for: .normal)
        setTitleColor(StyleProvider.Color.textPrimary, for: .normal)
        titleLabel?.font = StyleProvider.fontWith(type: .bold, size: 12)
        backgroundColor = StyleProvider.Color.inputBackground
        layer.cornerRadius = 4
        
        addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }
    
    @objc private func buttonTapped() {
        action?()
    }
}

// MARK: - SwiftUI Preview
#if DEBUG

@available(iOS 17.0, *)
#Preview("Default") {
    ZStack {
        Color.gray.opacity(0.1)
        PreviewUIView {
            BetInfoSubmissionView(viewModel: MockBetInfoSubmissionViewModel.defaultMock())
        }
    }
    .frame(height: 200)
    .padding()
}

@available(iOS 17.0, *)
#Preview("Sample Data") {
    ZStack {
        Color.gray.opacity(0.1)
        PreviewUIView {
            BetInfoSubmissionView(viewModel: MockBetInfoSubmissionViewModel.sampleMock())
        }
    }
    .frame(height: 200)
    .padding()
}

@available(iOS 17.0, *)
#Preview("Disabled") {
    ZStack {
        Color.gray.opacity(0.1)
        PreviewUIView {
            BetInfoSubmissionView(viewModel: MockBetInfoSubmissionViewModel.disabledMock())
        }
    }
    .frame(height: 200)
    .padding()
}

#endif 
