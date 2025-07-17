import UIKit
import Combine
import SwiftUI

public final class MatchDateNavigationBarView: UIView {
    
    // MARK: - UI Components
    private lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = StyleProvider.Color.backgroundPrimary
        return view
    }()
    
    private lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var backIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = StyleProvider.Color.iconPrimary
        if let image = UIImage(systemName: "chevron.left") {
            imageView.image = image.withRenderingMode(.alwaysTemplate)
        }
        return imageView
    }()
    
    private lazy var backLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .bold, size: 12)
        label.textColor = StyleProvider.Color.textPrimary
        return label
    }()
    
    private lazy var rightStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 0
        return stack
    }()
    
    private lazy var preMatchLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = StyleProvider.fontWith(type: .regular, size: 12)
        label.textColor = StyleProvider.Color.textPrimary
        return label
    }()
    
    private lazy var liveCapsuleViewModel: MockCapsuleViewModel = {
        return MockCapsuleViewModel.liveBadge
    }()
    
    private lazy var liveCapsuleView: CapsuleView = {
        let view = CapsuleView(viewModel: liveCapsuleViewModel)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Properties
    private let viewModel: MatchDateNavigationBarViewModelProtocol
    private var cancellables = Set<AnyCancellable>()
    private let dateFormatter = DateFormatter()
    
    // MARK: - Public Properties
    public var onBackTapped: (() -> Void) = { }
    
    // MARK: - Constants
    private enum Constants {
        static let height: CGFloat = 47.0
        static let horizontalPadding: CGFloat = 16.0
        static let backIconSize: CGFloat = 20.0
        static let backIconTextSpacing: CGFloat = 6.0
        static let livePillHorizontalPadding: CGFloat = 12.0
        static let livePillVerticalPadding: CGFloat = 4.0
        static let livePillCornerRadius: CGFloat = 12.0
    }
    
    // MARK: - Initialization
    public init(viewModel: MatchDateNavigationBarViewModelProtocol) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupViews()
        setupBindings()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Setup
    private func setupViews() {
        addSubview(containerView)
        containerView.addSubview(backButton)
        containerView.addSubview(backIconImageView)
        containerView.addSubview(backLabel)
        containerView.addSubview(rightStackView)
        
        // Add both views to stack
        rightStackView.addArrangedSubview(preMatchLabel)
        rightStackView.addArrangedSubview(liveCapsuleView)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Container
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            containerView.heightAnchor.constraint(equalToConstant: Constants.height),
            
            // Back icon
            backIconImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Constants.horizontalPadding),
            backIconImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            backIconImageView.widthAnchor.constraint(equalToConstant: Constants.backIconSize),
            backIconImageView.heightAnchor.constraint(equalToConstant: Constants.backIconSize),
            
            // Back label
            backLabel.leadingAnchor.constraint(equalTo: backIconImageView.trailingAnchor, constant: Constants.backIconTextSpacing),
            backLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            // Back button (covers icon and label)
            backButton.leadingAnchor.constraint(equalTo: backIconImageView.leadingAnchor),
            backButton.trailingAnchor.constraint(equalTo: backLabel.trailingAnchor),
            backButton.topAnchor.constraint(equalTo: containerView.topAnchor),
            backButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            // Right stack view (trailing aligned)
            rightStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Constants.horizontalPadding),
            rightStackView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])
    }
    
    private func setupBindings() {
        viewModel.dataPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] data in
                self?.configure(with: data)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Configuration
    private func configure(with data: MatchDateNavigationBarData) {
        // Configure back button
        backLabel.text = data.backButtonText
        backButton.isHidden = data.isBackButtonHidden
        backIconImageView.isHidden = data.isBackButtonHidden
        backLabel.isHidden = data.isBackButtonHidden
        
        // Configure date format
        dateFormatter.dateFormat = data.dateFormat
        
        // Configure status based on match state
        switch data.matchStatus {
        case .preMatch(let date):
            configurePreMatchState(date: date)
        case .live(let period, let time):
            configureLiveState(period: period, time: time)
        }
    }
    
    private func configurePreMatchState(date: Date) {
        // Show pre-match label, hide live capsule
        preMatchLabel.isHidden = false
        liveCapsuleView.isHidden = true
        
        // Configure pre-match text
        preMatchLabel.text = dateFormatter.string(from: date)
        
        // Split the text to apply different font weights
        if let text = preMatchLabel.text {
            let components = text.components(separatedBy: ",")
            if components.count >= 2 {
                let attributedString = NSMutableAttributedString()
                
                // Date part (bold)
                attributedString.append(NSAttributedString(
                    string: components[0],
                    attributes: [
                        .font: StyleProvider.fontWith(type: .bold, size: 12),
                        .foregroundColor: StyleProvider.Color.textPrimary
                    ]
                ))
                
                // Space
                attributedString.append(NSAttributedString(string: ", "))
                
                // Time part (regular)
                let datePart = components[1...].joined(separator: " ")
                attributedString.append(NSAttributedString(
                    string: datePart,
                    attributes: [
                        .font: StyleProvider.fontWith(type: .regular, size: 12),
                        .foregroundColor: StyleProvider.Color.textPrimary
                    ]
                ))
                
                preMatchLabel.attributedText = attributedString
            }
        }
    }
    
    private func configureLiveState(period: String, time: String) {
        // Hide pre-match label, show live capsule
        preMatchLabel.isHidden = true
        liveCapsuleView.isHidden = false
        
        // Configure live text - handle empty time properly
        let fullText = time.isEmpty ? period : "\(period), \(time)"
        
        // Update the CapsuleView with the live text
        let liveData = CapsuleData(
            text: fullText,
            backgroundColor: StyleProvider.Color.highlightSecondary,
            textColor: StyleProvider.Color.buttonTextPrimary,
            font: StyleProvider.fontWith(type: .bold, size: 10),
            horizontalPadding: 12.0,
            verticalPadding: 4.0
        )
        
        // Update the CapsuleView through the existing view model
        liveCapsuleViewModel.configure(with: liveData)
    }
    
    
    // MARK: - Actions
    @objc private func backButtonTapped() {
        onBackTapped()
    }
}


// MARK: - SwiftUI Preview
#if DEBUG

@available(iOS 17.0, *)
public struct MatchDateNavigationBarView_Previews: PreviewProvider {
    public static var previews: some View {
        VStack(spacing: 12) {
            PreviewUIView {
                let viewModel = MockMatchDateNavigationBarViewModel.defaultPreMatchMock
                return MatchDateNavigationBarView(viewModel: viewModel)
            }
            .frame(height: 44)
            .previewDisplayName("Pre-Match")
            
            PreviewUIView {
                let viewModel = MockMatchDateNavigationBarViewModel.liveMock
                return MatchDateNavigationBarView(viewModel: viewModel)
            }
            .frame(height: 44)
            .previewDisplayName("Live Match")
            
            PreviewUIView {
                let viewModel = MockMatchDateNavigationBarViewModel.noBackButtonMock
                return MatchDateNavigationBarView(viewModel: viewModel)
            }
            .frame(height: 44)
            .previewDisplayName("No Back Button")
        }
        .padding()
    }
}
#endif
