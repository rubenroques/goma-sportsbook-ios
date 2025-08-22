//
//  TimeSliderView.swift
//  GomaUI
//
//  Created by André Lascas on 27/05/2025.
//

import Foundation
import UIKit
import Combine

public class TimeSliderView: UIView {
    // MARK: - Properties
    private let headerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 8
        stackView.alignment = .center
        return stackView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Filter by Time"
        label.font = StyleProvider.fontWith(type: .bold, size: 12)
        label.textColor = StyleProvider.Color.textPrimary
        return label
    }()
    
    private let timeIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = StyleProvider.Color.highlightPrimary
        imageView.image = UIImage(systemName: "clock.fill")
        return imageView
    }()
    
    private lazy var slider: UISlider = {
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.minimumTrackTintColor = StyleProvider.Color.highlightPrimary
        slider.maximumTrackTintColor = .systemGray5
        
        if let thumbImage = UIImage(named: "slider_handle_icon", in: .main, compatibleWith: nil) {
            slider.setThumbImage(thumbImage, for: .normal)
            slider.setThumbImage(thumbImage, for: .highlighted)
        } else {
            // Fallback to circular thumb
            let thumbSize: CGFloat = 20
            let circularThumb = UIView(frame: CGRect(x: 0, y: 0, width: thumbSize, height: thumbSize))
            circularThumb.backgroundColor = StyleProvider.Color.highlightPrimary
            circularThumb.layer.cornerRadius = thumbSize / 2
            
            // Convert the UIView to UIImage
            let renderer = UIGraphicsImageRenderer(bounds: circularThumb.bounds)
            let thumbImage = renderer.image { context in
                circularThumb.layer.render(in: context.cgContext)
            }
            
            slider.setThumbImage(thumbImage, for: .normal)
            slider.setThumbImage(thumbImage, for: .highlighted)
        }
        
        return slider
    }()
    
    private var timeLabels: [UILabel] = []
    private var labelConstraints: [NSLayoutConstraint] = []
    private let viewModel: TimeSliderViewModelProtocol
    private var cancellables = Set<AnyCancellable>()
    
    public var onSliderValueChange: ((Float) -> Void)?
    
    // MARK: - Initialization
    public init(viewModel: TimeSliderViewModelProtocol) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupView()
        setupBindings()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupView() {
        backgroundColor = StyleProvider.Color.backgroundTertiary
        layer.cornerRadius = 8
        
        headerStackView.addArrangedSubview(timeIconImageView)
        headerStackView.addArrangedSubview(titleLabel)
        
        addSubview(headerStackView)
        addSubview(slider)
        
        NSLayoutConstraint.activate([
            headerStackView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            headerStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            
            timeIconImageView.widthAnchor.constraint(equalToConstant: 16),
            timeIconImageView.heightAnchor.constraint(equalToConstant: 16),
            
            slider.topAnchor.constraint(equalTo: headerStackView.bottomAnchor, constant: 16),
            slider.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            slider.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
        ])
        
        self.titleLabel.text = viewModel.title
        
        setupTimeOptions()
        slider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
    }
    
    private func setupTimeOptions() {
        timeLabels.forEach { $0.removeFromSuperview() }
        timeLabels.removeAll()
        
        slider.minimumValue = 0
        slider.maximumValue = Float(viewModel.timeOptions.count - 1)
        
        for option in viewModel.timeOptions {
            let label = UILabel()
            label.text = option.title
            label.font = StyleProvider.fontWith(type: .regular, size: 12)
            label.textColor = StyleProvider.Color.textPrimary
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            
            timeLabels.append(label)
            addSubview(label)
        }
        
        if let lastLabel = timeLabels.last {
            lastLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12).isActive = true
        }
        
        updateLabelsPosition()
    }
    
    private func setupBindings() {
        viewModel.selectedTimeValue
            .sink { [weak self] value in
                self?.slider.value = value
                self?.updateLabelsForValue(value)
                self?.onSliderValueChange?(value)
            }
            .store(in: &cancellables)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        updateLabelsPosition()
    }
    
    private func updateLabelsPosition() {
        // Remove previous constraints
        NSLayoutConstraint.deactivate(labelConstraints)
        labelConstraints.removeAll()
        
        let sliderWidth = slider.bounds.width
        let trackInset: CGFloat = 16
        let availableWidth = sliderWidth - (trackInset * 2)
        
        guard !timeLabels.isEmpty else { return }
        let segments = CGFloat(timeLabels.count - 1)
        
        for (index, label) in timeLabels.enumerated() {
            let position = CGFloat(index) / segments
            let xPosition = (availableWidth * position) + trackInset
            let labelWidth = (availableWidth / segments) - trackInset
            
            let centerXConstraint = label.centerXAnchor.constraint(equalTo: slider.leadingAnchor, constant: xPosition - 2)
            let topConstraint = label.topAnchor.constraint(equalTo: slider.bottomAnchor, constant: 6)
            let widthConstraint = label.widthAnchor.constraint(equalToConstant: labelWidth)
            
            labelConstraints.append(contentsOf: [centerXConstraint, topConstraint, widthConstraint])
        }
        
        // Activate all new constraints at once
        NSLayoutConstraint.activate(labelConstraints)
    }
    
    @objc private func sliderValueChanged() {
        viewModel.didChangeValue(slider.value)
        updateLabelsForValue(slider.value)
    }
    
    private func updateLabelsForValue(_ value: Float) {
        let roundedValue = round(value)
        timeLabels.enumerated().forEach { index, label in
            let isSelected = Int(roundedValue) == index
            label.textColor = isSelected ? StyleProvider.Color.highlightPrimary : StyleProvider.Color.textPrimary
        }
    }
}

#if DEBUG
import SwiftUI

@available(iOS 17.0, *)
struct TimeSliderView_Preview: PreviewProvider {
    static var previews: some View {
        PreviewUIView {
            let containerView = UIView()
            containerView.backgroundColor = .systemGray6
            
            let timeOptions = [
                TimeOption(title: "All", value: 0),
                TimeOption(title: "1h", value: 1),
                TimeOption(title: "8h", value: 2),
                TimeOption(title: "Today", value: 3),
                TimeOption(title: "48h", value: 4),
            ]
            
            let viewModel = MockTimeSliderViewModel(title: "Filter by Time", timeOptions: timeOptions)
            let sliderView = TimeSliderView(viewModel: viewModel)
            
            containerView.addSubview(sliderView)
            sliderView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                sliderView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
                sliderView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
                sliderView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16)
            ])
            
            return containerView
        }
        .frame(height: 160) // Reduced height to match the more compact design
        .background(Color(uiColor: .systemGray6))
    }
}
#endif
