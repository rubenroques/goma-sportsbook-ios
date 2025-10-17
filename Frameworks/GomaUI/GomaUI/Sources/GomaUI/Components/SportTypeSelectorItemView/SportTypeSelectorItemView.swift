import UIKit
import Combine
import SwiftUI

final public class SportTypeSelectorItemView: UIView {
    
    static let defaultHeight: CGFloat = 58
    
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
        
        titleLabel.font = StyleProvider.fontWith(type: .medium, size: 12)
        titleLabel.textColor = StyleProvider.Color.textPrimary
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 1
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -6),
            
            iconImageView.topAnchor.constraint(equalTo: containerView.topAnchor),
            iconImageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 23),
            iconImageView.heightAnchor.constraint(equalToConstant: 23),
            
            titleLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: -2),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            heightAnchor.constraint(equalToConstant: Self.defaultHeight)
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
        
        // Set icon - support both custom named images and system images
        if let customImage = UIImage(named: state.sportData.iconName) {
            iconImageView.image = customImage.withRenderingMode(.alwaysTemplate)
        } else {
            iconImageView.image = UIImage(systemName: state.sportData.iconName)
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
#Preview("SportTypeSelectorItemView") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = .backgroundTestColor

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false

        // Title label
        let titleLabel = UILabel()
        titleLabel.text = "SportTypeSelectorItemView"
        titleLabel.font = StyleProvider.fontWith(type: .bold, size: 18)
        titleLabel.textColor = StyleProvider.Color.textPrimary
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        // Football
        let footballView = SportTypeSelectorItemView(viewModel: MockSportTypeSelectorItemViewModel.footballMock)
        footballView.translatesAutoresizingMaskIntoConstraints = false

        // Basketball
        let basketballView = SportTypeSelectorItemView(viewModel: MockSportTypeSelectorItemViewModel.basketballMock)
        basketballView.translatesAutoresizingMaskIntoConstraints = false

        // Tennis
        let tennisView = SportTypeSelectorItemView(viewModel: MockSportTypeSelectorItemViewModel.tennisMock)
        tennisView.translatesAutoresizingMaskIntoConstraints = false

        // Baseball
        let baseballView = SportTypeSelectorItemView(viewModel: MockSportTypeSelectorItemViewModel.baseballMock)
        baseballView.translatesAutoresizingMaskIntoConstraints = false

        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(footballView)
        stackView.addArrangedSubview(basketballView)
        stackView.addArrangedSubview(tennisView)
        stackView.addArrangedSubview(baseballView)

        vc.view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16)
        ])

        return vc
    }
}

#endif
