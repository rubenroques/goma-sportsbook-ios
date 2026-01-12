import UIKit
import GomaUI

class CustomSliderViewController: UIViewController {
    
    private var defaultSlider: CustomSliderView!
    private var timeFilterSlider: CustomSliderView!
    private var volumeSlider: CustomSliderView!
    private var customImageSlider: CustomSliderView!
    private var statusLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Custom Slider"
        view.backgroundColor = StyleProvider.Color.backgroundPrimary
        setupViews()
    }
    
    private func setupViews() {
        // Create status label
        statusLabel = UILabel()
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.text = "Interact with the sliders below"
        statusLabel.font = StyleProvider.fontWith(type: .medium, size: 16)
        statusLabel.textColor = StyleProvider.Color.textPrimary
        statusLabel.textAlignment = .center
        statusLabel.numberOfLines = 0
        
        // Create default slider
        let defaultConfig = SliderConfiguration(
            minimumValue: 0.0,
            maximumValue: 1.0,
            numberOfSteps: 5,
            trackHeight: 4.0,
            trackCornerRadius: 2.0,
            thumbSize: 24.0
        )
        let defaultViewModel = MockCustomSliderViewModel.customMock(
            configuration: defaultConfig,
            initialValue: 0.0
        )
        defaultSlider = CustomSliderView(viewModel: defaultViewModel)
        defaultSlider.translatesAutoresizingMaskIntoConstraints = false
        
        // Create time filter slider (matches TimeSliderFilterView design)
        let timeFilterConfig = SliderConfiguration(
            minimumValue: 0.0,
            maximumValue: 1.0,
            numberOfSteps: 5,
            trackHeight: 4.0,
            trackCornerRadius: 2.0,
            thumbSize: 24.0
        )
        let timeFilterViewModel = MockCustomSliderViewModel.customMock(
            configuration: timeFilterConfig,
            initialValue: 0.5
        )
        timeFilterSlider = CustomSliderView(viewModel: timeFilterViewModel)
        timeFilterSlider.translatesAutoresizingMaskIntoConstraints = false
        
        // Create volume slider (different styling)
        let volumeConfig = SliderConfiguration(
            minimumValue: 0.0,
            maximumValue: 10.0,
            numberOfSteps: 11,
            trackHeight: 6.0,
            trackCornerRadius: 3.0,
            thumbSize: 28.0,
            thumbImageName: nil,
            thumbTintColor: nil
        )
        let volumeViewModel = MockCustomSliderViewModel.customMock(
            configuration: volumeConfig,
            initialValue: 7.0
        )
        volumeSlider = CustomSliderView(viewModel: volumeViewModel)
        volumeSlider.translatesAutoresizingMaskIntoConstraints = false
        
        // Create custom image slider (demonstrates custom thumb image)
        let customImageConfig = SliderConfiguration(
            minimumValue: 0.0,
            maximumValue: 1.0,
            numberOfSteps: 5,
            trackHeight: 4.0,
            trackCornerRadius: 2.0,
            thumbSize: 30.0,
            thumbImageName: "star.fill", // SF Symbol
            thumbTintColor: UIColor.systemYellow
        )
        let customImageViewModel = MockCustomSliderViewModel.customMock(
            configuration: customImageConfig,
            initialValue: 0.75
        )
        customImageSlider = CustomSliderView(viewModel: customImageViewModel)
        customImageSlider.translatesAutoresizingMaskIntoConstraints = false
        
        // Create section labels
        let defaultLabel = createSectionLabel(text: "Default Slider (5 steps)")
        let timeFilterLabel = createSectionLabel(text: "Time Filter Style (5 steps)")
        let volumeLabel = createSectionLabel(text: "Volume Slider (11 steps, larger)")
        let customImageLabel = createSectionLabel(text: "Custom Image Slider (star thumb, yellow)")
        
        // Add description label
        let descriptionLabel = UILabel()
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.text = "The CustomSliderView now supports custom thumb images with tinting! You can use SF Symbols, custom images, or the default circular thumb. Each slider can have different track heights, thumb sizes, images, and colors."
        descriptionLabel.textAlignment = .left
        descriptionLabel.numberOfLines = 0
        descriptionLabel.font = StyleProvider.fontWith(type: .regular, size: 14)
        descriptionLabel.textColor = StyleProvider.Color.highlightSecondary
        
        // Add all views
        view.addSubview(statusLabel)
        view.addSubview(defaultLabel)
        view.addSubview(defaultSlider)
        view.addSubview(timeFilterLabel)
        view.addSubview(timeFilterSlider)
        view.addSubview(volumeLabel)
        view.addSubview(volumeSlider)
        view.addSubview(customImageLabel)
        view.addSubview(customImageSlider)
        view.addSubview(descriptionLabel)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            // Status label
            statusLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            // Default slider section
            defaultLabel.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 30),
            defaultLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            defaultLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            defaultSlider.topAnchor.constraint(equalTo: defaultLabel.bottomAnchor, constant: 12),
            defaultSlider.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            defaultSlider.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            defaultSlider.heightAnchor.constraint(equalToConstant: 44),
            
            // Time filter slider section
            timeFilterLabel.topAnchor.constraint(equalTo: defaultSlider.bottomAnchor, constant: 30),
            timeFilterLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            timeFilterLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            timeFilterSlider.topAnchor.constraint(equalTo: timeFilterLabel.bottomAnchor, constant: 12),
            timeFilterSlider.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            timeFilterSlider.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            timeFilterSlider.heightAnchor.constraint(equalToConstant: 44),
            
            // Volume slider section
            volumeLabel.topAnchor.constraint(equalTo: timeFilterSlider.bottomAnchor, constant: 30),
            volumeLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            volumeLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            volumeSlider.topAnchor.constraint(equalTo: volumeLabel.bottomAnchor, constant: 12),
            volumeSlider.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            volumeSlider.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            volumeSlider.heightAnchor.constraint(equalToConstant: 50), // Larger for bigger thumb
            
            // Custom image slider section
            customImageLabel.topAnchor.constraint(equalTo: volumeSlider.bottomAnchor, constant: 30),
            customImageLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            customImageLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            customImageSlider.topAnchor.constraint(equalTo: customImageLabel.bottomAnchor, constant: 12),
            customImageSlider.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            customImageSlider.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            customImageSlider.heightAnchor.constraint(equalToConstant: 50), // Larger for custom image
            
            // Description label
            descriptionLabel.topAnchor.constraint(equalTo: customImageSlider.bottomAnchor, constant: 40),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
        
        // Setup slider callbacks
        setupSliderCallbacks()
    }
    
    private func createSectionLabel(text: String) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = text
        label.font = StyleProvider.fontWith(type: .medium, size: 14)
        label.textColor = StyleProvider.Color.textPrimary
        return label
    }
    
    private func setupSliderCallbacks() {
        // Default slider callbacks
        defaultSlider.onValueChanged = { [weak self] value in
            self?.updateStatus(for: "Default", value: value, isEditing: true)
        }
        
        defaultSlider.onEditingEnded = { [weak self] value in
            self?.updateStatus(for: "Default", value: value, isEditing: false)
        }
        
        // Time filter slider callbacks
        timeFilterSlider.onValueChanged = { [weak self] value in
            self?.updateStatus(for: "Time Filter", value: value, isEditing: true)
        }
        
        timeFilterSlider.onEditingEnded = { [weak self] value in
            self?.updateStatus(for: "Time Filter", value: value, isEditing: false)
        }
        
        // Volume slider callbacks
        volumeSlider.onValueChanged = { [weak self] value in
            self?.updateStatus(for: "Volume", value: value, isEditing: true)
        }
        
        volumeSlider.onEditingEnded = { [weak self] value in
            self?.updateStatus(for: "Volume", value: value, isEditing: false)
        }
        
        // Custom image slider callbacks
        customImageSlider.onValueChanged = { [weak self] value in
            self?.updateStatus(for: "Custom Image", value: value, isEditing: true)
        }
        
        customImageSlider.onEditingEnded = { [weak self] value in
            self?.updateStatus(for: "Custom Image", value: value, isEditing: false)
        }
    }
    
    private func updateStatus(for sliderName: String, value: Float, isEditing: Bool) {
        let status = isEditing ? "changing" : "set to"
        let formattedValue = String(format: "%.2f", value)
        statusLabel.text = "\(sliderName) slider \(status): \(formattedValue)"
        
        // In a real app, you would handle the value changes here
        print("\(sliderName) slider value: \(formattedValue) (editing: \(isEditing))")
    }
} 
