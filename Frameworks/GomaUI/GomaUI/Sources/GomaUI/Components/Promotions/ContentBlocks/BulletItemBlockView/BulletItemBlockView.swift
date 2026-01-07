//
//  BulletItemBlockView.swift
//  GomaUI
//
//  Created by André Lascas on 14/03/2025.
//

import UIKit

public class BulletItemBlockView: UIView {
    
    // MARK: Private properties
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private let viewModel: BulletItemBlockViewModelProtocol
    
    // MARK: - Lifetime and Cycle
    public init(viewModel: BulletItemBlockViewModelProtocol) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        self.commonInit()
        self.setupWithTheme()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func commonInit() {
        self.setupSubviews()
        self.configure()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func setupWithTheme() {
        self.backgroundColor = .clear
        self.titleLabel.textColor = StyleProvider.Color.highlightSecondaryContrast
    }
    
    // MARK: Functions
    private func configure() {
        let text = "• \(self.viewModel.title)"
        let attributedString = NSMutableAttributedString(string: text)
        let fullRange = (text as NSString).range(of: "• \(self.viewModel.title)")
        var range = (text as NSString).range(of: "•")
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.2
        paragraphStyle.lineSpacing = 2
        paragraphStyle.alignment = .left
        
        attributedString.addAttribute(.foregroundColor, value: StyleProvider.Color.textPrimary, range: fullRange)
        attributedString.addAttribute(.font, value: StyleProvider.fontWith(type: .semibold, size: 14), range: fullRange)
        
        while range.location != NSNotFound {
            attributedString.addAttribute(.foregroundColor, value: StyleProvider.Color.highlightPrimary, range: range)
            range = (text as NSString).range(of: "•", range: NSRange(location: range.location + 1, length: text.count - range.location - 1))
        }
        
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedString.length))
        
        self.titleLabel.attributedText = attributedString
    }
}

// MARK: - Subviews Initialization and Setup
extension BulletItemBlockView {
    
    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "• Title"
        label.font = StyleProvider.fontWith(type: .semibold, size: 16)
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }
    
    private func setupSubviews() {
        self.addSubview(self.titleLabel)
        self.initConstraints()
    }
    
    private func initConstraints() {
        NSLayoutConstraint.activate([
            self.titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15),
            self.titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -15),
            self.titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 5),
            self.titleLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5)
        ])
    }
}
