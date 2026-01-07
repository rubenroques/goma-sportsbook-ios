import UIKit
import Combine

public final class ToasterView: UIView {
    private let viewModel: ToasterViewModelProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // Container with rounded corners and shadow
    private lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = false
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.15
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 8
        return view
    }()
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 12
        return stack
    }()
    
    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .regular, size: 16)
        label.numberOfLines = 1
        return label
    }()
    
    public init(viewModel: ToasterViewModelProtocol) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupSubviews()
        setupConstraints()
        setupBindings()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setupSubviews() {
        addSubview(containerView)
        containerView.addSubview(stackView)
        stackView.addArrangedSubview(iconImageView)
        stackView.addArrangedSubview(titleLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20),
            
            iconImageView.widthAnchor.constraint(equalToConstant: 20),
            iconImageView.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    private func setupBindings() {
        viewModel.dataPublisher
            .receive(on: viewModel.scheduler)
            .sink { [weak self] data in
                self?.render(data: data)
            }
            .store(in: &cancellables)
    }
    
    private func render(data: ToasterData) {
        containerView.backgroundColor = data.backgroundColor
        containerView.layer.cornerRadius = data.cornerRadius
        titleLabel.text = data.title
        titleLabel.textColor = data.titleColor
        if let icon = data.icon {
            if let image = UIImage(named: icon)?.withRenderingMode(.alwaysTemplate) ?? UIImage(systemName: icon)?.withRenderingMode(.alwaysTemplate) {
                iconImageView.image = image
                iconImageView.tintColor = data.iconColor
                iconImageView.isHidden = false
            } else {
                iconImageView.isHidden = true
            }
        } else {
            iconImageView.isHidden = true
        }
    }
}

#if DEBUG
import SwiftUI

#Preview("Default Toaster") {
    PreviewUIViewController {
        let viewController = UIViewController()
        viewController.view.backgroundColor = .systemBackground
        let toaster = ToasterView(viewModel: MockToasterViewModel())
        toaster.translatesAutoresizingMaskIntoConstraints = false
        viewController.view.addSubview(toaster)
        NSLayoutConstraint.activate([
            toaster.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor, constant: 16),
            toaster.trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor, constant: -16),
            toaster.topAnchor.constraint(equalTo: viewController.view.safeAreaLayoutGuide.topAnchor, constant: 24)
        ])
        return viewController
    }
}
#endif


