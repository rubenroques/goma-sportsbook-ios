//
//  BulletItemBlockView.swift
//  Sportsbook
//
//  Created by André Lascas on 14/03/2025.
//

import UIKit

class BulletItemBlockView: UIView {

    // MARK: Private properties
    private lazy var titleLabel: UILabel = Self.createTitleLabel()

    // MARK: Lifetime and cycle
    init() {
                
        super.init(frame: .zero)

        self.setupSubviews()
        self.commonInit()
        self.setupWithTheme()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    private func commonInit() {
    }
    
    // MARK: Layout and theme
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
    func setupWithTheme() {
        self.backgroundColor = .clear
                
        self.titleLabel.textColor = UIColor.App.textPrimary
        
    }
    
    // MARK: Functions
    func configure(title: String) {
                        
        let text = "• \(title)"
        let attributedString = NSMutableAttributedString(string: text)
        let fullRange = (text as NSString).range(of: "• \(title)")
        var range = (text as NSString).range(of: "•")

        let paragraphStyle = NSMutableParagraphStyle()

        paragraphStyle.lineHeightMultiple = TextSpacing.subtitle
        paragraphStyle.lineSpacing = 2
        paragraphStyle.alignment = .left

        attributedString.addAttribute(.foregroundColor, value: UIColor.App.textPrimary, range: fullRange)
        attributedString.addAttribute(.font, value: AppFont.with(type: .semibold, size: 14), range: fullRange)

        while range.location != NSNotFound {
            attributedString.addAttribute(.foregroundColor, value: UIColor.App.highlightPrimary, range: range)
            range = (text as NSString).range(of: "•", range: NSRange(location: range.location + 1, length: text.count - range.location - 1))
        }

        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedString.length))

        self.titleLabel.attributedText = attributedString
        
    }
}

extension BulletItemBlockView {
    
    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "• Title"
        label.font = AppFont.with(type: .semibold, size: 14)
        label.textAlignment = .left
        return label
    }
    
    func setupSubviews() {
        
        self.addSubview(self.titleLabel)
        
        self.initConstraints()
    }
    
    func initConstraints() {
        
        NSLayoutConstraint.activate([
            
            self.titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15),
            self.titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -15),
            self.titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 5),
            self.titleLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5)
        ])
    }
}
