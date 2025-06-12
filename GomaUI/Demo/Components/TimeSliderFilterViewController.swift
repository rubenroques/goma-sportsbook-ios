import UIKit
import GomaUI

class TimeSliderFilterViewController: UIViewController {
    
    private var timeSliderView: TimeSliderView!
    private var statusLabel: UILabel!
    private var resetButton: UIButton!
    
    var timeSliderViewModel: MockTimeSliderViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Time Slider Filter"
        view.backgroundColor = StyleProvider.Color.backgroundColor
        setupViews()
    }
    
    private func setupViews() {
        // Create the time slider component
        let timeOptions = [
            TimeOption(title: "All", value: 0),
            TimeOption(title: "1h", value: 1),
            TimeOption(title: "8h", value: 2),
            TimeOption(title: "Today", value: 3),
            TimeOption(title: "48h", value: 4),
        ]
        
        let viewModel = MockTimeSliderViewModel(title: "Filter by Time", timeOptions: timeOptions, selectedValue: 2.0)
        self.timeSliderViewModel = viewModel
        
        timeSliderView = TimeSliderView(viewModel: viewModel)
        
        timeSliderView.translatesAutoresizingMaskIntoConstraints = false
        
        // Create status label to show current selection
        statusLabel = UILabel()
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.text = "Current selection: All"
        statusLabel.font = StyleProvider.fontWith(type: .medium, size: 16)
        statusLabel.textColor = StyleProvider.Color.textColor
        statusLabel.textAlignment = .center
        statusLabel.numberOfLines = 0
        
        // Create reset button
        resetButton = UIButton(type: .system)
        resetButton.translatesAutoresizingMaskIntoConstraints = false
        resetButton.setTitle("Reset to Default", for: .normal)
        resetButton.titleLabel?.font = StyleProvider.fontWith(type: .medium, size: 16)
        resetButton.setTitleColor(StyleProvider.Color.primaryColor, for: .normal)
        resetButton.layer.borderWidth = 1
        resetButton.layer.borderColor = StyleProvider.Color.primaryColor.cgColor
        resetButton.layer.cornerRadius = 8
        resetButton.contentEdgeInsets = UIEdgeInsets(top: 12, left: 24, bottom: 12, right: 24)
        resetButton.addTarget(self, action: #selector(resetButtonTapped), for: .touchUpInside)
        
        // Add description label
        let descriptionLabel = UILabel()
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.text = "The TimeSliderFilterView allows users to select time-based filters using either the slider or by tapping the labels directly. The slider snaps to discrete positions corresponding to each time option."
        descriptionLabel.textAlignment = .left
        descriptionLabel.numberOfLines = 0
        descriptionLabel.font = StyleProvider.fontWith(type: .regular, size: 14)
        descriptionLabel.textColor = StyleProvider.Color.secondaryColor
        
        // Add all views
        view.addSubview(timeSliderView)
        view.addSubview(statusLabel)
        view.addSubview(resetButton)
        view.addSubview(descriptionLabel)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            // Time slider view
            timeSliderView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            timeSliderView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            timeSliderView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            timeSliderView.heightAnchor.constraint(equalToConstant: 120),
            
            // Status label
            statusLabel.topAnchor.constraint(equalTo: timeSliderView.bottomAnchor, constant: 30),
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            // Reset button
            resetButton.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 20),
            resetButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // Description label
            descriptionLabel.topAnchor.constraint(equalTo: resetButton.bottomAnchor, constant: 40),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
        
        // Handle time filter selection
        timeSliderView.onSliderValueChange = { [weak self] sliderValue in
            self?.handleTimeFilterSelection("\(sliderValue)")
        }
    }
    
    private func handleTimeFilterSelection(_ sliderValue: String) {
        // Update status label based on selection
        let displayText: String
        switch sliderValue {
        case "0.0":
            displayText = "All time periods"
        case "1.0":
            displayText = "Last 1 hour"
        case "2.0":
            displayText = "Last 8 hours"
        case "3.0":
            displayText = "Today only"
        case "4.0":
            displayText = "Last 48 hours"
        default:
            displayText = "Unknown selection: \(sliderValue)"
        }
        
        statusLabel.text = "Current selection: \(displayText)"
        
        // In a real app, you would apply the filter here
        print("Time filter changed to: \(sliderValue)")
    }
    
    @objc private func resetButtonTapped() {
        
        timeSliderViewModel?.selectedTimeValue.send(2.0)
    }
} 
