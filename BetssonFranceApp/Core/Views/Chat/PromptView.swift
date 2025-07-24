//
//  PromptView.swift
//  MultiBet
//
//  Created by André Lascas on 14/05/2024.
//

import UIKit

class PromptView: UIView {

    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    
    var tappedPrompt: ((String) -> Void)?

    // MARK: Lifetime and Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)

        self.setupSubviews()
        self.commonInit()
        self.setupWithTheme()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.setupSubviews()
        self.commonInit()
        self.setupWithTheme()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        self.containerView.layer.cornerRadius = CornerRadius.view
    }

    func commonInit() {
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.didTapContainerView))
        self.containerView.addGestureRecognizer(tapGesture)
    }
    
    func setupWithTheme() {
        self.backgroundColor = .clear

        self.containerView.backgroundColor = UIColor.App.backgroundPrimary

        self.containerView.layer.borderColor = UIColor.App.highlightTertiary.cgColor
        
        self.titleLabel.textColor = UIColor.App.textPrimary
    }
    
    // MARK: Functions

    func configure(title: String) {
        self.titleLabel.text = title
    }
    
    @objc func didTapContainerView() {
        if let text = self.titleLabel.text {
            self.tappedPrompt?(text)
        }
    }
}

//
// MARK: Subviews initialization and setup
//
extension PromptView {

    private static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.borderWidth = 2
        return view
    }

    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Prompt"
        label.font = AppFont.with(type: .regular, size: 16)
        label.numberOfLines = 0
        return label
    }

    private func setupSubviews() {
        self.addSubview(self.containerView)

        self.containerView.addSubview(self.titleLabel)

        self.initConstraints()
    }

    private func initConstraints() {

        // Container view
        NSLayoutConstraint.activate([
            self.containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.containerView.topAnchor.constraint(equalTo: self.topAnchor),
            self.containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor),

            self.titleLabel.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 10),
            self.titleLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -10),
            self.titleLabel.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: 10),
            self.titleLabel.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor, constant: -10)
        ])

    }

}
