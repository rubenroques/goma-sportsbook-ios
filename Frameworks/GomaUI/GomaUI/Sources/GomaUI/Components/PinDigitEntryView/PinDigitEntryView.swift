import Foundation
import UIKit
import Combine
import SwiftUI

public final class PinDigitEntryView: UIView {
    
    // MARK: - UI Components
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 12
        return stackView
    }()
    
    private var digitFields: [PinDigitField] = []
    private var hiddenTextField: UITextField = {
        let textField = UITextField()
        textField.isHidden = true
        textField.keyboardType = .numberPad
        return textField
    }()
    
    // MARK: - Properties
    private let viewModel: PinDigitEntryViewModelProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Public Properties
    public var onPinCompleted: ((String) -> Void) = { _ in }
    
    // MARK: - Initialization
    public init(viewModel: PinDigitEntryViewModelProtocol = MockPinDigitEntryViewModel.defaultMock) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupViews()
        setupBindings()
        setupKeyboardHandling()
    }
    
    required init?(coder: NSCoder) {
        self.viewModel = MockPinDigitEntryViewModel.defaultMock
        super.init(coder: coder)
        setupViews()
        setupBindings()
        setupKeyboardHandling()
    }
    
    // MARK: - Private Methods
    private func setupViews() {
        backgroundColor = .clear
        
        addSubview(stackView)
        addSubview(hiddenTextField)
        
        setupConstraints()
        createDigitFields()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func createDigitFields() {
        let data = viewModel.data
        
        // Clear existing fields
        digitFields.forEach { $0.removeFromSuperview() }
        digitFields.removeAll()
        
        // Create new fields
        for index in 0..<data.digitCount {
            let field = PinDigitField()
            field.tag = index
            field.onTapped = { [weak self] in
                self?.focusField(at: index)
            }
            
            digitFields.append(field)
            stackView.addArrangedSubview(field)
        }
        
        updateFieldsAppearance()
    }
    
    private func setupBindings() {
        viewModel.dataPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] data in
                self?.configure(with: data)
            }
            .store(in: &cancellables)
        
        viewModel.isPinComplete
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] isPinComplete in
                
                print("Pin complete status: \(isPinComplete)")
            })
            .store(in: &cancellables)
    }
    
    private func setupKeyboardHandling() {
        hiddenTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        // Add tap gesture to focus
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        addGestureRecognizer(tapGesture)
    }
    
    private func configure(with data: PinDigitEntryData) {
        if digitFields.count != data.digitCount {
            createDigitFields()
        }
        updateFieldsAppearance()
    }
    
    private func updateFieldsAppearance() {
        let data = viewModel.data
        let digits = Array(data.currentPin)
        
        for (index, field) in digitFields.enumerated() {
            if index < digits.count {
                field.setDigit(String(digits[index]))
                field.setState(.filled)
            } else if index == data.currentPin.count {
                field.setDigit("")
                field.setState(.focused)
            } else {
                field.setDigit("")
                field.setState(.empty)
            }
        }
    }
    
    public func focusField(at index: Int) {
        hiddenTextField.becomeFirstResponder()
    }
    
    @objc private func viewTapped() {
        hiddenTextField.becomeFirstResponder()
    }
    
    @objc private func textFieldDidChange() {
        guard let text = hiddenTextField.text else { return }
        
        let currentPin = viewModel.data.currentPin
        let currentIsPinComplete = viewModel.isPinComplete.value
        
        if text.count > currentPin.count {
            // Digit was added
            let newDigit = String(text.suffix(1))
            if newDigit.rangeOfCharacter(from: CharacterSet.decimalDigits) != nil {
                viewModel.addDigit(newDigit)
                
                if viewModel.data.currentPin.count == viewModel.data.digitCount {
                    if !currentIsPinComplete {
                        viewModel.isPinComplete.send(true)
                    }
                    onPinCompleted(viewModel.data.currentPin)
                    hiddenTextField.resignFirstResponder()
                }
                
            }
        } else if text.count < currentPin.count {
            // Digit was removed
            viewModel.removeLastDigit()
            if currentIsPinComplete {
                viewModel.isPinComplete.send(false)
            }
        }
        
        // Keep hidden text field in sync
        hiddenTextField.text = viewModel.data.currentPin
    }
    
    // MARK: - Public Methods
    public func clearPin() {
        viewModel.clearPin()
        hiddenTextField.text = ""
    }
    
    public func focusInput() {
        hiddenTextField.becomeFirstResponder()
    }
    
    public func resignFocus() {
        hiddenTextField.resignFirstResponder()
    }
}

// MARK: - SwiftUI Preview
#if DEBUG

@available(iOS 17.0, *)
#Preview("PinDigitEntryView") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = StyleProvider.Color.backgroundPrimary

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 24
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false

        // Component name label
        let titleLabel = UILabel()
        titleLabel.text = "PinDigitEntryView"
        titleLabel.font = StyleProvider.fontWith(type: .bold, size: 18)
        titleLabel.textColor = StyleProvider.Color.textPrimary
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        // 4-digit PIN (empty)
        let fourDigitView = PinDigitEntryView(viewModel: MockPinDigitEntryViewModel.defaultMock)
        fourDigitView.translatesAutoresizingMaskIntoConstraints = false

        // 6-digit PIN (partially filled with "123")
        let sixDigitView = PinDigitEntryView(viewModel: MockPinDigitEntryViewModel.sixDigitMock)
        sixDigitView.translatesAutoresizingMaskIntoConstraints = false

        // 8-digit PIN (empty)
        let eightDigitView = PinDigitEntryView(viewModel: MockPinDigitEntryViewModel.eightDigitMock)
        eightDigitView.translatesAutoresizingMaskIntoConstraints = false

        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(fourDigitView)
        stackView.addArrangedSubview(sixDigitView)
        stackView.addArrangedSubview(eightDigitView)

        vc.view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -20)
        ])

        return vc
    }
}
#endif
