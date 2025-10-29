//
//  HighlightDescriptionView.swift
//  Sportsbook
//
//  Created by André Lascas on 28/10/2025.
//

import UIKit

struct HighlightedText {
    let text: String
    let isHighlighted: Bool
}

class HighlightDescriptionView: UIView {

    // MARK: - Private Properties
    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var stackView: UIStackView = Self.createStackView()
    
    private var labels: [UILabel] = []

    // MARK: - Lifetime and Cycle
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
    }
    
    private func commonInit() {
    }

    // MARK: - Layout and Theme
    func setupWithTheme() {
        self.backgroundColor = UIColor.App.backgroundPrimary
        self.containerView.backgroundColor = .clear
        self.stackView.backgroundColor = .clear
    }

    // MARK: - Functions
    func configure(texts: [HighlightedText]) {
        // Clear existing labels
        self.labels.forEach { $0.removeFromSuperview() }
        self.labels.removeAll()
        
        // Create labels for each text
        for highlightedText in texts {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = highlightedText.text
            label.font = AppFont.with(type: .regular, size: 14)
            label.numberOfLines = 0
            label.textAlignment = .left
            
            if highlightedText.isHighlighted {
                label.textColor = UIColor.App.highlightPrimary
            } else {
                label.textColor = UIColor.App.textPrimary
            }
            
            self.stackView.addArrangedSubview(label)
            self.labels.append(label)
        }
    }
}

//
// MARK: - Subviews initialization and setup
//
extension HighlightDescriptionView {

    private static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 22
        return stackView
    }

    private func setupSubviews() {
        self.addSubview(self.containerView)
        
        self.containerView.addSubview(self.stackView)

        self.initConstraints()
    }

    private func initConstraints() {
        NSLayoutConstraint.activate([
            // Container view fills the parent
            self.containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.containerView.topAnchor.constraint(equalTo: self.topAnchor),
            self.containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor),

            // Stack view with padding
            self.stackView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 20),
            self.stackView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -20),
            self.stackView.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: 20),
            self.stackView.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor, constant: -20)
        ])
    }
}
