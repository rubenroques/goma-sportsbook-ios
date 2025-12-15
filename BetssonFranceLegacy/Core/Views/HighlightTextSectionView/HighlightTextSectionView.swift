//
//  HighlightTextSectionView.swift
//  Sportsbook
//
//  Created by André Lascas on 28/10/2025.
//

import UIKit

class HighlightTextSectionView: UIView {

    // MARK: - Private Properties
    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var descriptionLabel: UILabel = Self.createDescriptionLabel()
    
    private let viewModel: HighlightTextSectionViewModelProtocol

    // MARK: - Lifetime and Cycle
    init(viewModel: HighlightTextSectionViewModelProtocol) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        
        self.setupSubviews()
        self.commonInit()
        self.setupWithTheme()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func commonInit() {
        self.bind(toViewModel: self.viewModel)
    }

    // MARK: - Layout and Theme
    func setupWithTheme() {
        self.backgroundColor = UIColor.App.backgroundPrimary
        self.containerView.backgroundColor = .clear
        
        // Title in bright orange
        self.titleLabel.textColor = UIColor.App.highlightPrimary
        
        // Description in light gray
        self.descriptionLabel.textColor = UIColor.App.textPrimary
    }

    // MARK: - Functions
    private func bind(toViewModel viewModel: HighlightTextSectionViewModelProtocol) {
        self.titleLabel.text = viewModel.title
        self.titleLabel.font = viewModel.titleFont ?? AppFont.with(type: .bold, size: 16)
        self.titleLabel.textColor = viewModel.titleColor ?? UIColor.App.highlightPrimary
        
        self.descriptionLabel.text = viewModel.description
        self.descriptionLabel.font = viewModel.descriptionFont ?? AppFont.with(type: .regular, size: 14)
        self.descriptionLabel.textColor = viewModel.descriptionColor ?? UIColor.App.textPrimary
    }
}

//
// MARK: - Subviews initialization and setup
//
extension HighlightTextSectionView {

    private static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = ""
        label.font = AppFont.with(type: .bold, size: 16)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }

    private static func createDescriptionLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = ""
        label.font = AppFont.with(type: .regular, size: 14)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }

    private func setupSubviews() {
        self.addSubview(self.containerView)
        
        self.containerView.addSubview(self.titleLabel)
        self.containerView.addSubview(self.descriptionLabel)

        self.initConstraints()
    }

    private func initConstraints() {
        NSLayoutConstraint.activate([
            // Container view fills the parent
            self.containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.containerView.topAnchor.constraint(equalTo: self.topAnchor),
            self.containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor),

            // Title label
            self.titleLabel.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 20),
            self.titleLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -20),
            self.titleLabel.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: 20),
            
            // Description label
            self.descriptionLabel.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 20),
            self.descriptionLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -20),
            self.descriptionLabel.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 16),
            self.descriptionLabel.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor, constant: -20)
        ])
    }
}
