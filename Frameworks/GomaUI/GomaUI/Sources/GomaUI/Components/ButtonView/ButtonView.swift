import Foundation
import UIKit
import Combine
import SwiftUI

final public class ButtonView: UIView {
    // MARK: - Private Properties
    private let button: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.layer.cornerRadius = 8
        btn.titleLabel?.font = StyleProvider.fontWith(type: .bold, size: 16)
        return btn
    }()
    
    private var cancellables = Set<AnyCancellable>()
    private var currentButtonData: ButtonData?
    
    // MARK: - Public Properties
    public var onButtonTapped: (() -> Void) = { }
    
    let viewModel: ButtonViewModelProtocol

    // MARK: - Initialization
    public init(viewModel: ButtonViewModelProtocol) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupSubviews()
        setupBindings()
        setupActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupSubviews() {
        backgroundColor = .clear
        
        addSubview(button)
        
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: topAnchor),
            button.leadingAnchor.constraint(equalTo: leadingAnchor),
            button.trailingAnchor.constraint(equalTo: trailingAnchor),
            button.bottomAnchor.constraint(equalTo: bottomAnchor),
            button.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupBindings() {
        viewModel.buttonDataPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] buttonData in
                self?.configure(buttonData: buttonData)
            }
            .store(in: &cancellables)
    }
    
    private func setupActions() {
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }
    
    // MARK: - Configuration
    private func configure(buttonData: ButtonData) {
        currentButtonData = buttonData
        
        // Set title
        button.setTitle(buttonData.title, for: .normal)
        
        // Apply custom font if provided
        applyFont(buttonData.fontSize, fontType: buttonData.fontType)
        
        // Apply style based on button type and state
        applyStyle(buttonData.style, isEnabled: buttonData.isEnabled)
        
        // Update enabled state
        button.isEnabled = buttonData.isEnabled
    }
    
    private func applyFont(_ fontSize: CGFloat?, fontType: StyleProvider.FontType?) {
        let finalFontSize = fontSize ?? 16.0 // Default to current size
        let finalFontType = fontType ?? .bold // Default to current type
        
        button.titleLabel?.font = StyleProvider.fontWith(type: finalFontType, size: finalFontSize)
    }
    
    private func applyStyle(_ style: ButtonStyle, isEnabled: Bool) {
        switch style {
        case .solidBackground:
            applySolidBackgroundStyle(isEnabled: isEnabled)
        case .bordered:
            applyBorderedStyle(isEnabled: isEnabled)
        case .transparent:
            applyTransparentStyle(isEnabled: isEnabled)
        }
    }
    
    private func applySolidBackgroundStyle(isEnabled: Bool) {
        if isEnabled {
            if let customBackgroundColor = currentButtonData?.backgroundColor {
                button.backgroundColor = customBackgroundColor
            }
            else {
                button.backgroundColor = StyleProvider.Color.buttonBackgroundPrimary
            }
            
            if let customTextColor = currentButtonData?.textColor {
                button.setTitleColor(customTextColor, for: .normal)
            } else {
                button.setTitleColor(StyleProvider.Color.buttonTextPrimary, for: .normal)
            }
        } else {
            if let customDisabledBackgroundColor = currentButtonData?.disabledBackgroundColor {
                button.backgroundColor = customDisabledBackgroundColor
            }
            else {
                button.backgroundColor = StyleProvider.Color.buttonDisablePrimary
            }
            button.setTitleColor(StyleProvider.Color.buttonTextDisablePrimary, for: .normal)
        }
        
        button.layer.borderWidth = 0
        button.layer.borderColor = UIColor.clear.cgColor
    }
    
    private func applyBorderedStyle(isEnabled: Bool) {
        button.backgroundColor = .clear
        
        if isEnabled {
            button.layer.borderWidth = 2
            
            if let customBorderColor = currentButtonData?.borderColor {
                button.layer.borderColor = customBorderColor.cgColor
            } else {
                button.layer.borderColor = StyleProvider.Color.highlightPrimary.cgColor
            }
            
            if let customTextColor = currentButtonData?.textColor {
                button.setTitleColor(customTextColor, for: .normal)
            } else if let customBorderColor = currentButtonData?.borderColor {
                // Use border color as text color if no explicit text color is provided
                button.setTitleColor(customBorderColor, for: .normal)
            } else {
                button.setTitleColor(StyleProvider.Color.highlightPrimary, for: .normal)
            }
        } else {
            button.layer.borderWidth = 2
            button.layer.borderColor = StyleProvider.Color.buttonDisablePrimary.cgColor
            button.setTitleColor(StyleProvider.Color.buttonTextDisablePrimary, for: .normal)
        }
    }
    
    private func applyTransparentStyle(isEnabled: Bool) {
        button.backgroundColor = .clear
        button.layer.borderWidth = 0
        button.layer.borderColor = UIColor.clear.cgColor
        
        if isEnabled {
            let textColor = currentButtonData?.textColor ?? StyleProvider.Color.buttonTextPrimary
            button.setTitleColor(textColor, for: .normal)
            
            // Add underline for transparent buttons
            let attributes: [NSAttributedString.Key: Any] = [
                .underlineStyle: NSUnderlineStyle.single.rawValue,
                .font: StyleProvider.fontWith(type: .bold, size: 16),
                .foregroundColor: textColor
            ]
            let attributedTitle = NSAttributedString(string: button.currentTitle ?? "", attributes: attributes)
            button.setAttributedTitle(attributedTitle, for: .normal)
        } else {
            button.setTitleColor(StyleProvider.Color.buttonTextDisablePrimary, for: .normal)
            
            // Add underline for disabled state too
            let attributes: [NSAttributedString.Key: Any] = [
                .underlineStyle: NSUnderlineStyle.single.rawValue,
                .font: StyleProvider.fontWith(type: .bold, size: 16),
                .foregroundColor: StyleProvider.Color.buttonTextDisablePrimary
            ]
            let attributedTitle = NSAttributedString(string: button.currentTitle ?? "", attributes: attributes)
            button.setAttributedTitle(attributedTitle, for: .normal)
        }
    }
    
    // MARK: - Actions
    @objc private func buttonTapped() {
        guard let buttonData = currentButtonData, buttonData.isEnabled else { return }
        
        // Add haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        viewModel.buttonTapped()
        onButtonTapped()
    }
    
    // MARK: - Public Methods
    public func setCustomHeight(_ height: CGFloat) {
        button.heightAnchor.constraint(equalToConstant: height).isActive = true
    }
    
    public func setCustomFontSize(_ size: CGFloat) {
        button.titleLabel?.font = StyleProvider.fontWith(type: .bold, size: size)
    }
    
    public func setCustomBackgroundColor(_ color: UIColor) {
        button.backgroundColor = color
    }
}

// MARK: - Preview Provider
#if DEBUG

@available(iOS 17.0, *)
#Preview("All Button States") {
    VStack(spacing: 20) {
        PreviewUIView {
            ButtonView(viewModel: MockButtonViewModel.solidBackgroundMock)
        }
        .frame(height: 50)
        
        PreviewUIView {
            ButtonView(viewModel: MockButtonViewModel.solidBackgroundDisabledMock)
        }
        .frame(height: 50)
        
        PreviewUIView {
            ButtonView(viewModel: MockButtonViewModel.borderedMock)
        }
        .frame(height: 50)
        
        PreviewUIView {
            ButtonView(viewModel: MockButtonViewModel.borderedDisabledMock)
        }
        .frame(height: 50)
        
        PreviewUIView {
            ButtonView(viewModel: MockButtonViewModel.transparentMock)
        }
        .frame(height: 50)
        .background(Color.cyan)
        
        PreviewUIView {
            ButtonView(viewModel: MockButtonViewModel.transparentDisabledMock)
        }
        .frame(height: 50)
        .background(Color.cyan)

    }
    .padding()
}

@available(iOS 17.0, *)
#Preview("Custom Color Examples") {
    VStack(spacing: 20) {
        PreviewUIView {
            ButtonView(viewModel: MockButtonViewModel.solidBackgroundCustomColorMock)
        }
        .frame(height: 50)
        
        PreviewUIView {
            ButtonView(viewModel: MockButtonViewModel.borderedCustomColorMock)
        }
        .frame(height: 50)
        
        PreviewUIView {
            ButtonView(viewModel: MockButtonViewModel.transparentCustomColorMock)
        }
        .frame(height: 50)
        .background(Color.gray.opacity(0.2))
        
        PreviewUIView {
            ButtonView(viewModel: MockButtonViewModel.redThemeMock)
        }
        .frame(height: 50)
        
        PreviewUIView {
            ButtonView(viewModel: MockButtonViewModel.blueThemeMock)
        }
        .frame(height: 50)
        
        PreviewUIView {
            ButtonView(viewModel: MockButtonViewModel.greenThemeMock)
        }
        .frame(height: 50)
        
        PreviewUIView {
            ButtonView(viewModel: MockButtonViewModel.orangeThemeMock)
        }
        .frame(height: 50)
    }
    .padding()
}

@available(iOS 17.0, *)
#Preview("Color Themes Comparison") {
    HStack(spacing: 15) {
        VStack(spacing: 10) {
            PreviewUIView {
                ButtonView(viewModel: MockButtonViewModel.redThemeMock)
            }
            .frame(height: 50)
            
            PreviewUIView {
                ButtonView(viewModel: MockButtonViewModel.greenThemeMock)
            }
            .frame(height: 50)
        }
        
        VStack(spacing: 10) {
            PreviewUIView {
                ButtonView(viewModel: MockButtonViewModel.blueThemeMock)
            }
            .frame(height: 50)
            
            PreviewUIView {
                ButtonView(viewModel: MockButtonViewModel.orangeThemeMock)
            }
            .frame(height: 50)
        }
    }
    .padding()
}

@available(iOS 17.0, *)
#Preview("Font Customization Examples") {
    VStack(spacing: 15) {
        PreviewUIView {
            ButtonView(viewModel: MockButtonViewModel.largeFontMock)
        }
        .frame(height: 60) // Taller for large font
        
        PreviewUIView {
            ButtonView(viewModel: MockButtonViewModel.smallFontMock)
        }
        .frame(height: 40) // Shorter for small font
        
        PreviewUIView {
            ButtonView(viewModel: MockButtonViewModel.lightFontMock)
        }
        .frame(height: 50)
        
        PreviewUIView {
            ButtonView(viewModel: MockButtonViewModel.heavyFontMock)
        }
        .frame(height: 50)
        
        PreviewUIView {
            ButtonView(viewModel: MockButtonViewModel.customFontStyleMock)
        }
        .frame(height: 50)
        .background(Color.gray.opacity(0.1))
    }
    .padding()
}

@available(iOS 17.0, *)
#Preview("Font Weight Comparison") {
    VStack(spacing: 12) {
        Text("Font Weight Showcase")
            .font(.headline)
            .padding(.bottom, 5)
        
        HStack(spacing: 10) {
            PreviewUIView {
                ButtonView(viewModel: MockButtonViewModel.lightFontMock)
            }
            .frame(height: 50)
            
            PreviewUIView {
                ButtonView(viewModel: MockButtonViewModel.customFontStyleMock)
            }
            .frame(height: 50)
        }
        
        HStack(spacing: 10) {
            PreviewUIView {
                ButtonView(viewModel: MockButtonViewModel.largeFontMock)
            }
            .frame(height: 50)
            
            PreviewUIView {
                ButtonView(viewModel: MockButtonViewModel.heavyFontMock)
            }
            .frame(height: 50)
        }
    }
    .padding()
}

#endif
