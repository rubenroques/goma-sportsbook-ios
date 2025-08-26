import UIKit
import Combine

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
    }
}

// MARK: - SwiftUI Preview
#if canImport(SwiftUI) && DEBUG
import SwiftUI

@available(iOS 13.0, *)
struct BetDetailRowPreviewView: UIViewRepresentable {
    private let viewModel: BetDetailRowViewModelProtocol
    private let cornerStyle: BetDetailRowCornerStyle
    
    init(viewModel: BetDetailRowViewModelProtocol, cornerStyle: BetDetailRowCornerStyle = .none) {
        self.viewModel = viewModel
        self.cornerStyle = cornerStyle
    }
    
    func makeUIView(context: Context) -> BetDetailRowView {
        let view = BetDetailRowView(viewModel: viewModel, cornerStyle: cornerStyle)
        return view
    }
    
    func updateUIView(_ uiView: BetDetailRowView, context: Context) {
        // Updates handled by Combine binding
    }
}

@available(iOS 13.0, *)
struct BetDetailRowView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // No corners
            BetDetailRowPreviewView(
                viewModel: MockBetDetailRowViewModel.defaultMock(),
                cornerStyle: .none
            )
            .frame(height: 48)
            .padding()
            .background(Color.gray.opacity(0.1))
            .previewDisplayName("No Corners")
            
            // Top corners only
            BetDetailRowPreviewView(
                viewModel: MockBetDetailRowViewModel.defaultMock(),
                cornerStyle: .topOnly(radius: 8)
            )
            .frame(height: 48)
            .padding()
            .background(Color.gray.opacity(0.1))
            .previewDisplayName("Top Corners Only")
            
            // Bottom corners only
            BetDetailRowPreviewView(
                viewModel: MockBetDetailRowViewModel.defaultMock(),
                cornerStyle: .bottomOnly(radius: 8)
            )
            .frame(height: 48)
            .padding()
            .background(Color.gray.opacity(0.1))
            .previewDisplayName("Bottom Corners Only")
        }
    }
}
#endif
