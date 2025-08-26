import UIKit
import Combine

public class BetTicketStatusView: UIView {
    
    // MARK: - Properties
    private let viewModel: BetTicketStatusViewModelProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Components
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 8
        view.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        return view
    }()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.widthAnchor.constraint(equalToConstant: 24).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 24).isActive = true
        imageView.backgroundColor = .clear
        return imageView
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .bold, size: 16)
        label.textColor = StyleProvider.Color.allWhite
        return label
    }()
    
    // MARK: - Initialization
    public init(viewModel: BetTicketStatusViewModelProtocol) {
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
        containerView.addSubview(iconImageView)
        containerView.addSubview(statusLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Container constraints
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 48),
            
            // Icon constraints
            iconImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            iconImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            // Status label constraints
            statusLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 12),
            statusLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
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
    private func updateUI(with data: BetTicketStatusData) {
        // Update visibility
        isHidden = !data.isVisible
        
        // Update appearance based on status
        switch data.status {
        case .won:
            containerView.backgroundColor = StyleProvider.Color.highlightSecondary
            if let customImage = UIImage(named: "success_circle_icon") {
                iconImageView.image = customImage
            }
            else {
                iconImageView.image = UIImage(systemName: "checkmark.circle.fill")
            }
            iconImageView.tintColor = StyleProvider.Color.allWhite
            statusLabel.text = "Won"
            
        case .lost:
            containerView.backgroundColor = StyleProvider.Color.backgroundGradient2
            if let customImage = UIImage(named: "error_icon") {
                iconImageView.image = customImage
            }
            else {
                iconImageView.image = UIImage(systemName: "xmark")
            }
            iconImageView.tintColor = StyleProvider.Color.alertError
            statusLabel.text = "Lost"
            statusLabel.textColor = StyleProvider.Color.alertError

        case .draw:
            containerView.backgroundColor = StyleProvider.Color.alertWarning
            if let customImage = UIImage(named: "alert_icon") {
                iconImageView.image = customImage
            }
            else {
                iconImageView.image = UIImage(systemName: "minus")
            }
            iconImageView.tintColor = StyleProvider.Color.allWhite
            statusLabel.text = "Draw"
        }
    }
}

// MARK: - SwiftUI Preview
#if canImport(SwiftUI) && DEBUG
import SwiftUI

@available(iOS 13.0, *)
struct BetTicketStatusPreviewView: UIViewRepresentable {
    private let viewModel: BetTicketStatusViewModelProtocol
    
    init(viewModel: BetTicketStatusViewModelProtocol) {
        self.viewModel = viewModel
    }
    
    func makeUIView(context: Context) -> BetTicketStatusView {
        let view = BetTicketStatusView(viewModel: viewModel)
        return view
    }
    
    func updateUIView(_ uiView: BetTicketStatusView, context: Context) {
        // Updates handled by Combine binding
    }
}

@available(iOS 13.0, *)
struct BetTicketStatusView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Won state
            BetTicketStatusPreviewView(
                viewModel: MockBetTicketStatusViewModel.wonMock()
            )
            .frame(height: 48)
            .padding()
            .background(Color.gray.opacity(0.1))
            .previewDisplayName("Won State")
            
            // Lost state
            BetTicketStatusPreviewView(
                viewModel: MockBetTicketStatusViewModel.lostMock()
            )
            .frame(height: 48)
            .padding()
            .background(Color.gray.opacity(0.1))
            .previewDisplayName("Lost State")
            
            // Draw state
            BetTicketStatusPreviewView(
                viewModel: MockBetTicketStatusViewModel.drawMock()
            )
            .frame(height: 48)
            .padding()
            .background(Color.gray.opacity(0.1))
            .previewDisplayName("Draw State")
        }
    }
}
#endif
