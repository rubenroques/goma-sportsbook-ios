import UIKit

/// Individual theme segment view component
internal final class ThemeSegmentView: UIView {
    
    private lazy var iconImageView: UIImageView = Self.createIconImageView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var stackView: UIStackView = Self.createStackView()
    
    private let theme: ThemeMode
    private var onTapCallback: ((ThemeMode) -> Void)?
    
    init(theme: ThemeMode) {
        self.theme = theme
        super.init(frame: .zero)
        setupSubviews()
        setupActions()
        configureContent()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private static func createIconImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = StyleProvider.Color.textPrimary
        return imageView
    }
    
    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .semibold, size: 14)
        label.textColor = StyleProvider.Color.textPrimary
        label.textAlignment = .center
        return label
    }
    
    private static func createStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 4
        return stackView
    }
    
    private func setupSubviews() {
        addSubview(stackView)
        stackView.addArrangedSubview(iconImageView)
        stackView.addArrangedSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            stackView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 8),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -8),
            
            iconImageView.widthAnchor.constraint(equalToConstant: 14),
            iconImageView.heightAnchor.constraint(equalToConstant: 14)
        ])
    }
    
    private func setupActions() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapGesture)
    }
    
    private func configureContent() {
        iconImageView.image = UIImage(systemName: theme.iconName)
        titleLabel.text = theme.displayName
    }
    
    func setSelected(_ selected: Bool) {
        let color = selected ? StyleProvider.Color.buttonTextPrimary : StyleProvider.Color.textPrimary
        iconImageView.tintColor = color
        titleLabel.textColor = color
    }
    
    func setOnTapCallback(_ callback: @escaping (ThemeMode) -> Void) {
        self.onTapCallback = callback
    }
    
    @objc private func handleTap() {
        onTapCallback?(theme)
    }
}
