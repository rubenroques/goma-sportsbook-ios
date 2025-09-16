import UIKit
import SwiftUI

final public class QuickLinkTabBarItemView: UIView {
    // MARK: - UI Elements
    private lazy var iconImageView: UIImageView = Self.createIconImageView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var containerStackView: UIStackView = Self.createContainerStackView()

    // MARK: - Properties
    public var onTap: (() -> Void)?
    private(set) var linkType: QuickLinkType?

    // MARK: - Initialization
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
        setupGestures()
    }

    public convenience init() {
        self.init(frame: .zero)
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateTheme() {
        self.backgroundColor = StyleProvider.Color.backgroundSecondary
        self.iconImageView.tintColor = StyleProvider.Color.iconSecondary
        self.titleLabel.textColor = StyleProvider.Color.iconSecondary
    }

    // MARK: - Configuration
    public func configure(with item: QuickLinkItem) {
        self.linkType = item.type
        self.iconImageView.image = item.icon?.withRenderingMode(.alwaysTemplate)
        self.titleLabel.text = item.title
        
        self.iconImageView.tintColor = StyleProvider.Color.iconSecondary
        self.titleLabel.textColor = StyleProvider.Color.iconSecondary
    }

    // MARK: - Private Methods
    private func setupSubviews() {
        self.translatesAutoresizingMaskIntoConstraints = false
        addSubview(self.containerStackView)

        self.containerStackView.addArrangedSubview(self.iconImageView)
        self.containerStackView.addArrangedSubview(self.titleLabel)

        updateTheme()
        initConstraints()
    }

    private func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapGesture)
        isUserInteractionEnabled = true
    }

    @objc private func handleTap() {
        onTap?()
    }
}

// MARK: - Factory Methods
private extension QuickLinkTabBarItemView {
    static func createContainerStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 2
        return stackView
    }

    static func createIconImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = StyleProvider.Color.iconSecondary
        return imageView
    }

    static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .regular, size: 12.0)
        label.textAlignment = .center
        label.textColor = StyleProvider.Color.iconSecondary
        return label
    }
}

// MARK: - Constraints
private extension QuickLinkTabBarItemView {
    func initConstraints() {
        NSLayoutConstraint.activate([
            containerStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
            containerStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4),
            containerStackView.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            containerStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4),

            iconImageView.widthAnchor.constraint(equalToConstant: 20),
            iconImageView.heightAnchor.constraint(equalToConstant: 17),

            titleLabel.heightAnchor.constraint(equalToConstant: 16)
        ])
    }
}

#if DEBUG
import SwiftUI

@available(iOS 17.0, *)
#Preview("Quick Link Item") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = StyleProvider.Color.backgroundColor
        
        let item = QuickLinkItem(
            type: .aviator,
            title: "Aviator",
            icon: UIImage(systemName: "airplane")
        )
        
        let itemView = QuickLinkTabBarItemView()
        itemView.configure(with: item)
        itemView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(itemView)
        
        NSLayoutConstraint.activate([
            itemView.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            itemView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor),
            itemView.widthAnchor.constraint(equalToConstant: 70),
            itemView.heightAnchor.constraint(equalToConstant: 48)
        ])
        
        return vc
    }
}
#endif
