import UIKit
import Combine

public class CashoutSliderView: UIView {
    
    // MARK: - Properties
    private let viewModel: CashoutSliderViewModelProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Components
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = StyleProvider.Color.backgroundPrimary
        view.layer.cornerRadius = 12
        return view
    }()
    
    // Header section with title and value labels
    private let headerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .regular, size: 12)
        label.textColor = StyleProvider.Color.textPrimary
        label.textAlignment = .center
        return label
    }()
    
    private let minimumValueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .regular, size: 14)
        label.textColor = StyleProvider.Color.textPrimary
        label.textAlignment = .left
        return label
    }()
    
    private let maximumValueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .regular, size: 14)
        label.textColor = StyleProvider.Color.textPrimary
        label.textAlignment = .right
        return label
    }()
    
    // Slider section
    private let sliderView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let slider: UISlider = {
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.minimumTrackTintColor = StyleProvider.Color.highlightPrimary
        slider.maximumTrackTintColor = StyleProvider.Color.backgroundSecondary
        slider.thumbTintColor = StyleProvider.Color.highlightPrimary
        
        // Create a smaller thumb with highlightPrimary color
        let thumbSize: CGFloat = 16
        
        if let customThumbImage = UIImage(named: "slider_thumb_icon")?.withConfiguration(
            UIImage.SymbolConfiguration(pointSize: thumbSize, weight: .medium)
        ).withTintColor(StyleProvider.Color.highlightPrimary, renderingMode: .alwaysOriginal) {
            slider.setThumbImage(customThumbImage, for: .normal)
            slider.setThumbImage(customThumbImage, for: .highlighted)
            slider.setThumbImage(customThumbImage, for: .selected)
            slider.setThumbImage(customThumbImage, for: .disabled)
        }
        else if let thumbImage = UIImage(systemName: "circle.fill")?.withConfiguration(
            UIImage.SymbolConfiguration(pointSize: thumbSize, weight: .medium)
        ).withTintColor(StyleProvider.Color.highlightPrimary, renderingMode: .alwaysOriginal) {
            slider.setThumbImage(thumbImage, for: .normal)
            slider.setThumbImage(thumbImage, for: .highlighted)
            slider.setThumbImage(thumbImage, for: .selected)
            slider.setThumbImage(thumbImage, for: .disabled)
        }
        
        return slider
    }()
    
    // Button section
    private lazy var buttonView: ButtonView = {
        let button = ButtonView(viewModel: viewModel.buttonViewModel)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Initialization
    public init(viewModel: CashoutSliderViewModelProtocol) {
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
        
        // Header setup
        containerView.addSubview(headerView)
        headerView.addSubview(titleLabel)
        headerView.addSubview(minimumValueLabel)
        headerView.addSubview(maximumValueLabel)
        
        // Slider setup
        containerView.addSubview(sliderView)
        sliderView.addSubview(slider)
        
        // Button setup
        containerView.addSubview(buttonView)
        
        // Add slider target
        slider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Container constraints
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // Header constraints
            headerView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            headerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            headerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            
            titleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: headerView.topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor),
            
            minimumValueLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            minimumValueLabel.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            
            maximumValueLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
            maximumValueLabel.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            
            // Slider constraints
            sliderView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 8),
            sliderView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            sliderView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            
            slider.topAnchor.constraint(equalTo: sliderView.topAnchor),
            slider.leadingAnchor.constraint(equalTo: sliderView.leadingAnchor),
            slider.trailingAnchor.constraint(equalTo: sliderView.trailingAnchor),
            slider.bottomAnchor.constraint(equalTo: sliderView.bottomAnchor),
            
            // Button constraints
            buttonView.topAnchor.constraint(equalTo: sliderView.bottomAnchor, constant: 18),
            buttonView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            buttonView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            buttonView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8)
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
    private func updateUI(with data: CashoutSliderData) {
        // Update header
        titleLabel.text = data.title
        minimumValueLabel.text = String(format: "%.1f", data.minimumValue)
        maximumValueLabel.text = String(format: "%.0f", data.maximumValue)
        
        // Update slider
        slider.minimumValue = data.minimumValue
        slider.maximumValue = data.maximumValue
        slider.value = data.currentValue
        slider.isEnabled = data.isEnabled
        
        // Update button title through the button view model
        viewModel.buttonViewModel.updateTitle(data.selectionTitle)
        viewModel.buttonViewModel.setEnabled(data.isEnabled)
        
    }
    
    // MARK: - Actions
    @objc private func sliderValueChanged(_ sender: UISlider) {
        viewModel.updateSliderValue(sender.value)
    }
}

// MARK: - SwiftUI Preview
#if canImport(SwiftUI) && DEBUG
import SwiftUI

@available(iOS 13.0, *)
struct CashoutSliderPreviewView: UIViewRepresentable {
    private let viewModel: CashoutSliderViewModelProtocol
    
    init(viewModel: CashoutSliderViewModelProtocol) {
        self.viewModel = viewModel
    }
    
    func makeUIView(context: Context) -> CashoutSliderView {
        let view = CashoutSliderView(viewModel: viewModel)
        return view
    }
    
    func updateUIView(_ uiView: CashoutSliderView, context: Context) {
        // Updates handled by Combine binding
    }
}

@available(iOS 13.0, *)
struct CashoutSliderView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Default state
            CashoutSliderPreviewView(
                viewModel: MockCashoutSliderViewModel.defaultMock()
            )
            .frame(height: 130)
            .padding()
            .background(Color.gray.opacity(0.1))
            .previewDisplayName("Default State")
            
            // Maximum value
            CashoutSliderPreviewView(
                viewModel: MockCashoutSliderViewModel.maximumMock()
            )
            .frame(height: 130)
            .padding()
            .background(Color.gray.opacity(0.1))
            .previewDisplayName("Maximum Value")
            
            // Minimum value
            CashoutSliderPreviewView(
                viewModel: MockCashoutSliderViewModel.minimumMock()
            )
            .frame(height: 130)
            .padding()
            .background(Color.gray.opacity(0.1))
            .previewDisplayName("Minimum Value")
        }
    }
}
#endif 
