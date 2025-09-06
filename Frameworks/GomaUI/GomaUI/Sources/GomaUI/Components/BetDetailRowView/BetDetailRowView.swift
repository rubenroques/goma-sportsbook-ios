import UIKit
import Combine
import SwiftUI

public class BetDetailRowView: UIView {
    
    // MARK: - Properties
    private let viewModel: BetDetailRowViewModelProtocol
    private var cancellables = Set<AnyCancellable>()
    private let cornerStyle: BetDetailRowCornerStyle
    
    // MARK: - UI Components
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = StyleProvider.Color.backgroundTertiary
        return view
    }()
    
    private let labelLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .regular, size: 14)
        label.textColor = StyleProvider.Color.textSecondary
        return label
    }()
    
    private let valueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .bold, size: 14)
        label.textColor = StyleProvider.Color.textPrimary
        label.textAlignment = .right
        return label
    }()
    
    // MARK: - Initialization
    public init(viewModel: BetDetailRowViewModelProtocol, cornerStyle: BetDetailRowCornerStyle = .none) {
        self.viewModel = viewModel
        self.cornerStyle = cornerStyle
        
        super.init(frame: .zero)
        
        setupView()
        setupConstraints()
        setupCornerRadius()
        bindViewModel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupView() {
        addSubview(containerView)
        containerView.addSubview(labelLabel)
        containerView.addSubview(valueLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Container constraints
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 52),
            
            // Label constraints
            labelLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            labelLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            // Value label constraints
            valueLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            valueLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])
    }
    
    private func setupCornerRadius() {
        switch cornerStyle {
        case .none:
            containerView.layer.cornerRadius = 0
            containerView.layer.maskedCorners = []
            
        case .topOnly(let radius):
            containerView.layer.cornerRadius = radius
            containerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            
        case .bottomOnly(let radius):
            containerView.layer.cornerRadius = radius
            containerView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            
        case .all(let radius):
            containerView.layer.cornerRadius = radius
        }
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
    private func updateUI(with data: BetDetailRowData) {
        labelLabel.text = data.label
        valueLabel.text = data.value
        
        // Apply style-specific updates
        switch data.style {
        case .standard:
            setupStandardStyle()
        case .header:
            setupHeaderStyle()
        }
    }
    
    private func setupStandardStyle() {
        containerView.backgroundColor = StyleProvider.Color.backgroundTertiary
        labelLabel.font = StyleProvider.fontWith(type: .regular, size: 14)
        labelLabel.textColor = StyleProvider.Color.textSecondary
        labelLabel.textAlignment = .left
        
        valueLabel.font = StyleProvider.fontWith(type: .bold, size: 14)
        valueLabel.textColor = StyleProvider.Color.textPrimary
        valueLabel.textAlignment = .right
        valueLabel.isHidden = false
    }
    
    private func setupHeaderStyle() {
        containerView.backgroundColor = StyleProvider.Color.backgroundTertiary
        labelLabel.font = StyleProvider.fontWith(type: .regular, size: 14)
        labelLabel.textColor = StyleProvider.Color.textPrimary
        labelLabel.textAlignment = .center
        
        // Hide value label for header style
        valueLabel.isHidden = true
    }
}

// MARK: - SwiftUI Preview
#if DEBUG

@available(iOS 17.0, *)
#Preview("Bet Detail Row - Standard") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = StyleProvider.Color.backgroundColor
        
        let rowView = BetDetailRowView(viewModel: MockBetDetailRowViewModel.defaultMock(), cornerStyle: .none)
        rowView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(rowView)
        
        NSLayoutConstraint.activate([
            rowView.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            rowView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor),
            rowView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            rowView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16)
        ])
        
        return vc
    }
}

@available(iOS 17.0, *)
#Preview("Bet Detail Row - Top Corners") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = StyleProvider.Color.backgroundColor
        
        let rowView = BetDetailRowView(viewModel: MockBetDetailRowViewModel.defaultMock(), cornerStyle: .topOnly(radius: 8))
        rowView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(rowView)
        
        NSLayoutConstraint.activate([
            rowView.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            rowView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor),
            rowView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            rowView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16)
        ])
        
        return vc
    }
}

@available(iOS 17.0, *)
#Preview("Bet Detail Row - Bottom Corners") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = StyleProvider.Color.backgroundColor
        
        let rowView = BetDetailRowView(viewModel: MockBetDetailRowViewModel.defaultMock(), cornerStyle: .bottomOnly(radius: 8))
        rowView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(rowView)
        
        NSLayoutConstraint.activate([
            rowView.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            rowView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor),
            rowView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            rowView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16)
        ])
        
        return vc
    }
}

@available(iOS 17.0, *)
#Preview("Bet Detail Row - Header Style") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = StyleProvider.Color.backgroundColor
        
        let rowView = BetDetailRowView(viewModel: MockBetDetailRowViewModel.headerMock(), cornerStyle: .none)
        rowView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(rowView)
        
        NSLayoutConstraint.activate([
            rowView.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            rowView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor),
            rowView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            rowView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16)
        ])
        
        return vc
    }
}

#endif
