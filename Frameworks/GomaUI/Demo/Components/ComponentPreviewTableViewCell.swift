import UIKit
import GomaUI

class ComponentPreviewTableViewCell: UITableViewCell {
    
    // MARK: - UI Components
    private let containerStackView = UIStackView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let previewContainerView = UIView()
    private let separatorView = UIView()
    
    // MARK: - Layout Constants
    private struct Constants {
        static let verticalPadding: CGFloat = 16.0
        static let horizontalPadding: CGFloat = 20.0
        static let previewHeight: CGFloat = 80.0
        static let spacing: CGFloat = 12.0
        static let cornerRadius: CGFloat = 12.0
        static let borderWidth: CGFloat = 1.0
    }
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
        setupStyling()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    private func setupViews() {
        contentView.addSubview(containerStackView)
        
        containerStackView.addArrangedSubview(titleLabel)
        containerStackView.addArrangedSubview(descriptionLabel)
        containerStackView.addArrangedSubview(previewContainerView)
        containerStackView.addArrangedSubview(separatorView)
        
        // Container stack view setup
        containerStackView.axis = .vertical
        containerStackView.spacing = Constants.spacing
        containerStackView.alignment = .fill
        containerStackView.distribution = .fill
        
        // Title label setup
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 1
        
        // Description label setup
        descriptionLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.numberOfLines = 2
        
        // Preview container setup
        previewContainerView.layer.cornerRadius = Constants.cornerRadius
        previewContainerView.layer.borderWidth = Constants.borderWidth
        previewContainerView.layer.borderColor = UIColor.separator.cgColor
        previewContainerView.backgroundColor = .systemBackground
        previewContainerView.clipsToBounds = true
        
        // Separator setup
        separatorView.backgroundColor = .separator
    }
    
    private func setupConstraints() {
        containerStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Container stack view
            containerStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.verticalPadding),
            containerStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.horizontalPadding),
            containerStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.horizontalPadding),
            containerStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.verticalPadding),
            
            // Preview container height
            previewContainerView.heightAnchor.constraint(equalToConstant: Constants.previewHeight),
            
            // Separator height
            separatorView.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
    
    private func setupStyling() {
        backgroundColor = .systemGroupedBackground
        selectionStyle = .default
        
        // Add subtle shadow to preview container
        previewContainerView.layer.shadowColor = UIColor.black.cgColor
        previewContainerView.layer.shadowOffset = CGSize(width: 0, height: 1)
        previewContainerView.layer.shadowRadius = 2
        previewContainerView.layer.shadowOpacity = 0.1
    }
    
    // MARK: - Configuration
    func configure(with component: UIComponent, previewView: UIView) {
        titleLabel.text = component.title
        descriptionLabel.text = component.description
        
        // Clear any existing preview
        clearPreview()
        
        // Add new preview
        addPreview(previewView)
    }
    
    private func clearPreview() {
        previewContainerView.subviews.forEach { $0.removeFromSuperview() }
    }
    
    private func addPreview(_ previewView: UIView) {
        previewContainerView.addSubview(previewView)
        previewView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            previewView.topAnchor.constraint(equalTo: previewContainerView.topAnchor, constant: 8),
            previewView.leadingAnchor.constraint(equalTo: previewContainerView.leadingAnchor, constant: 8),
            previewView.trailingAnchor.constraint(equalTo: previewContainerView.trailingAnchor, constant: -8),
            previewView.bottomAnchor.constraint(equalTo: previewContainerView.bottomAnchor, constant: -8)
        ])
    }
    
    // MARK: - Reuse
    override func prepareForReuse() {
        super.prepareForReuse()
        clearPreview()
        titleLabel.text = nil
        descriptionLabel.text = nil
    }
} 
