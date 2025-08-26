import UIKit
import Combine

public class CashoutSubmissionInfoView: UIView {
    
    // MARK: - Properties
    private let viewModel: CashoutSubmissionInfoViewModelProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Components
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 12
        return view
    }()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.widthAnchor.constraint(equalToConstant: 24).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 24).isActive = true
        return imageView
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .regular, size: 14)
        label.textColor = .white
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var buttonView: ButtonView = {
        let button = ButtonView(viewModel: viewModel.buttonViewModel)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Initialization
    public init(viewModel: CashoutSubmissionInfoViewModelProtocol) {
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
        containerView.addSubview(messageLabel)
        containerView.addSubview(buttonView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Container constraints
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 56),
            
            // Icon constraints
            iconImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            iconImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            // Message label constraints
            messageLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 12),
            messageLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            // Button constraints
            buttonView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            buttonView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
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
    private func updateUI(with data: CashoutSubmissionInfoData) {
        // Update visibility
        isHidden = !data.isVisible
        
        // Update message
        messageLabel.text = data.message
        
        // Update appearance based on state
        switch data.state {
        case .success:
            containerView.backgroundColor = StyleProvider.Color.highlightSecondary
            if let customImage = UIImage(named: "success_circle_icon") {
                iconImageView.image = customImage
            }
            else {
                iconImageView.image = UIImage(systemName: "checkmark.circle.fill")
            }
            iconImageView.tintColor = .white
            
        case .error:
            containerView.backgroundColor = StyleProvider.Color.highlightPrimary
            if let customImage = UIImage(named: "alert_icon") {
                iconImageView.image = customImage
            }
            else {
                iconImageView.image = UIImage(systemName: "exclamationmark.triangle.fill")
            }
            iconImageView.tintColor = .white
        }
    }
}

// MARK: - SwiftUI Preview
#if canImport(SwiftUI) && DEBUG
import SwiftUI

@available(iOS 13.0, *)
struct CashoutSubmissionInfoPreviewView: UIViewRepresentable {
    private let viewModel: CashoutSubmissionInfoViewModelProtocol
    
    init(viewModel: CashoutSubmissionInfoViewModelProtocol) {
        self.viewModel = viewModel
    }
    
    func makeUIView(context: Context) -> CashoutSubmissionInfoView {
        let view = CashoutSubmissionInfoView(viewModel: viewModel)
        return view
    }
    
    func updateUIView(_ uiView: CashoutSubmissionInfoView, context: Context) {
        // Updates handled by Combine binding
    }
}

@available(iOS 13.0, *)
struct CashoutSubmissionInfoView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Success state
            CashoutSubmissionInfoPreviewView(
                viewModel: MockCashoutSubmissionInfoViewModel.successMock()
            )
            .frame(height: 56)
            .padding()
            .background(Color.gray.opacity(0.1))
            .previewDisplayName("Success State")
            
            // Error state
            CashoutSubmissionInfoPreviewView(
                viewModel: MockCashoutSubmissionInfoViewModel.errorMock()
            )
            .frame(height: 56)
            .padding()
            .background(Color.gray.opacity(0.1))
            .previewDisplayName("Error State")
        }
    }
}
#endif
