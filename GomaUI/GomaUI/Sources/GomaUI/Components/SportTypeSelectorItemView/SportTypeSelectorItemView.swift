import UIKit
import Combine
import SwiftUI

final public class SportTypeSelectorItemView: UIView {
    // MARK: - Private Properties
    private let containerView = UIView()
    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    private var cancellables = Set<AnyCancellable>()
    private let viewModel: SportTypeSelectorItemViewModelProtocol
    
    // MARK: - Public Properties
    public var onTap: ((SportTypeData) -> Void) = { _ in }
    private var currentSportData: SportTypeData?
    
    // MARK: - Initialization
    public init(viewModel: SportTypeSelectorItemViewModelProtocol) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupSubviews()
        setupBindings()
        setupGesture()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupSubviews() {
        backgroundColor = StyleProvider.Color.backgroundSecondary
        layer.cornerRadius = 8
        
        addSubview(containerView)
        containerView.addSubview(iconImageView)
        containerView.addSubview(titleLabel)
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = StyleProvider.Color.textPrimary
        
        titleLabel.font = StyleProvider.fontWith(type: .regular, size: 12)
        titleLabel.textColor = StyleProvider.Color.textPrimary
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 1
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor, constant: 6),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -6),
            
            iconImageView.topAnchor.constraint(equalTo: containerView.topAnchor),
            iconImageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 4),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            heightAnchor.constraint(equalToConstant: 56)
        ])
    }
    
    private func setupBindings() {
        viewModel.displayStatePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] displayState in
                self?.render(state: displayState)
            }
            .store(in: &cancellables)
    }
    
    private func setupGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapGesture)
        isUserInteractionEnabled = true
    }
    
    // MARK: - Rendering
    private func render(state: SportTypeSelectorItemDisplayState) {
        currentSportData = state.sportData
        titleLabel.text = state.sportData.name
        
        // Set icon - for now using system images, can be replaced with custom icons
        let iconName = mapSportToSystemIcon(state.sportData.iconName)
        iconImageView.image = UIImage(systemName: iconName)
    }
    
    private func mapSportToSystemIcon(_ sportIconName: String) -> String {
        switch sportIconName.lowercased() {
        case "football", "soccer":
            return "soccerball"
        case "basketball":
            return "basketball"
        case "tennis":
            return "tennisball"
        case "baseball":
            return "baseball"
        case "hockey":
            return "hockey.puck"
        case "golf":
            return "golf.stick.and.ball"
        case "volleyball":
            return "volleyball"
        default:
            return "sportscourt"
        }
    }
    
    // MARK: - Actions
    @objc private func handleTap() {
        guard let sportData = currentSportData else { return }
        onTap(sportData)
    }
}

// MARK: - Preview Provider
#if DEBUG

@available(iOS 17.0, *)
#Preview("Default") {
    PreviewUIView {
        SportTypeSelectorItemView(viewModel: MockSportTypeSelectorItemViewModel.footballMock)
    }
    .frame(width: 150, height: 56)
}

@available(iOS 17.0, *)
#Preview("Multiple Sports") {
    VStack(spacing: 8) {
        HStack(spacing: 8) {
            PreviewUIView {
                SportTypeSelectorItemView(viewModel: MockSportTypeSelectorItemViewModel.footballMock)
            }
            .frame(width: 150, height: 56)
            
            PreviewUIView {
                SportTypeSelectorItemView(viewModel: MockSportTypeSelectorItemViewModel.basketballMock)
            }
            .frame(width: 150, height: 56)
        }
        
        HStack(spacing: 8) {
            PreviewUIView {
                SportTypeSelectorItemView(viewModel: MockSportTypeSelectorItemViewModel.tennisMock)
            }
            .frame(width: 150, height: 56)
            
            PreviewUIView {
                SportTypeSelectorItemView(viewModel: MockSportTypeSelectorItemViewModel.baseballMock)
            }
            .frame(width: 150, height: 56)
        }
    }
}

#endif
