import UIKit
import Combine
import SwiftUI

final public class PromotionalHeaderView: UIView {
    // MARK: - Private Properties
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        return view
    }()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = StyleProvider.Color.highlightPrimary
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .bold, size: 14)
        label.textColor = StyleProvider.Color.textPrimary
        label.numberOfLines = 0
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .regular, size: 12)
        label.textColor = StyleProvider.Color.textSecondary
        label.numberOfLines = 0
        return label
    }()
    
    private let textStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .leading
        return stack
    }()
    
    private let mainStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        return stack
    }()
    
    private var cancellables = Set<AnyCancellable>()
    private let viewModel: PromotionalHeaderViewModelProtocol
    
    // MARK: - Initialization
    public init(viewModel: PromotionalHeaderViewModelProtocol) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupSubviews()
        setupData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupSubviews() {
        backgroundColor = .clear
        
        addSubview(containerView)
        containerView.addSubview(mainStackView)
        
        textStackView.addArrangedSubview(titleLabel)
        textStackView.addArrangedSubview(subtitleLabel)
        
        mainStackView.addArrangedSubview(iconImageView)
        mainStackView.addArrangedSubview(textStackView)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),
            
            mainStackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            mainStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            mainStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            mainStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8)
        ])
    }
    
    private func setupData() {
        
        let headerData = viewModel.getHeaderData()
        
        // Update icon
        if let iconImage = UIImage(systemName: headerData.icon) {
            iconImageView.image = iconImage
        } else if let iconImage = UIImage(named: headerData.icon) {
            iconImageView.image = iconImage
        }
        
        // Update title
        titleLabel.text = headerData.title
        
        // Update subtitle (handle optional)
        if let subtitle = headerData.subtitle, !subtitle.isEmpty {
            subtitleLabel.text = subtitle
            subtitleLabel.isHidden = false
        } else {
            subtitleLabel.isHidden = true
        }
        
    }
    
    // MARK: - Public Methods
    public func setCustomBackgroundColor(_ color: UIColor) {
        containerView.backgroundColor = color
    }
}

// MARK: - Preview Provider
#if DEBUG

@available(iOS 17.0, *)
#Preview("Multiple Header Examples") {
    VStack(spacing: 16) {
        PreviewUIView {
            let view = PromotionalHeaderView(viewModel: MockPromotionalHeaderViewModel.defaultMock)
            
            view.setCustomBackgroundColor(StyleProvider.Color.backgroundColor)
            
            return view
        }
        .frame(height: 60)
        
        
        PreviewUIView {
            PromotionalHeaderView(viewModel: MockPromotionalHeaderViewModel.noSubtitleMock)
        }
        .frame(height: 60)
    }
}

#endif 
