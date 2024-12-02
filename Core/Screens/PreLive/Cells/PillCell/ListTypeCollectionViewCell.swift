//
//  ListTypeCollectionViewCell.swift
//  Sportsbook
//
//  Created by Ruben Roques on 01/10/2021.
//

import UIKit

class ListTypeCollectionViewCell: UICollectionViewCell {

    static let cellHeight: CGFloat = 42

    private lazy var selectionHighlightView: UIView = Self.createSelectionHighlightView()
    private lazy var labelView: UIView = Self.createLabelView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()

    var selectedColor: UIColor = .white
    var normalColor: UIColor = .black

    var selectedType: Bool = false
    var isCustomDesign: Bool = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setupSubviews()
        self.setupWithTheme()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.setupWithTheme()
        self.setSelectedType(false)
    }

    func setupWithTheme() {
        self.normalColor = UIColor.App.pillBackground
        self.selectedColor = UIColor.App.highlightPrimary
        self.selectionHighlightView.backgroundColor = UIColor.App.highlightPrimary
        self.labelView.backgroundColor = UIColor.App.pillBackground
        
        self.setupWithSelection(self.selectedType)
        
        self.titleLabel.textColor = UIColor.App.textPrimary
    }

    func setupWithTitle(_ title: String) {
        self.titleLabel.text = title
        
        if self.isCustomDesign {
            let text = title
            let attributedString = NSMutableAttributedString(string: text)
            let fullRange = (text as NSString).range(of: title)
            let range = (text as NSString).range(of: localized("mix_match_mix_string"))
            
            attributedString.addAttribute(.foregroundColor, value: UIColor.App.textPrimary, range: fullRange)
            attributedString.addAttribute(.font, value: AppFont.with(type: .semibold, size: 14), range: fullRange)
            
            attributedString.addAttribute(.foregroundColor, value: UIColor.App.highlightPrimary, range: range)
            
            self.titleLabel.attributedText = attributedString
        }
    }

    func setSelectedType(_ selected: Bool) {
        self.selectedType = selected
        self.setupWithSelection(self.selectedType)
    }

    func setupWithSelection(_ selected: Bool) {
        if selected {
            self.selectionHighlightView.backgroundColor = self.selectedColor
            self.labelView.backgroundColor = self.normalColor
        }
        else {
            self.selectionHighlightView.backgroundColor = self.normalColor
            self.labelView.backgroundColor = self.normalColor
        }
    }
}

// MARK: - UI Creation
extension ListTypeCollectionViewCell {
    
    private static func createSelectionHighlightView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = (Self.cellHeight - 2) / 2
        return view
    }
    
    private static func createLabelView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = (Self.cellHeight - 4) / 2
        return view
    }
    
    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .bold, size: 14)
        return label
    }
    
    private func setupSubviews() {
        self.contentView.addSubview(self.selectionHighlightView)
        self.selectionHighlightView.addSubview(self.labelView)
        self.labelView.addSubview(self.titleLabel)
        
        self.initConstraints()
    }
    
    private func initConstraints() {
        NSLayoutConstraint.activate([
            self.contentView.heightAnchor.constraint(equalToConstant: Self.cellHeight),
            
            self.selectionHighlightView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            self.selectionHighlightView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            self.selectionHighlightView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            self.selectionHighlightView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
            
            self.labelView.leadingAnchor.constraint(equalTo: self.selectionHighlightView.leadingAnchor, constant: 2),
            self.labelView.trailingAnchor.constraint(equalTo: self.selectionHighlightView.trailingAnchor, constant: -2),
            self.labelView.topAnchor.constraint(equalTo: self.selectionHighlightView.topAnchor, constant: 2),
            self.labelView.bottomAnchor.constraint(equalTo: self.selectionHighlightView.bottomAnchor, constant: -2),
            
            self.titleLabel.leadingAnchor.constraint(equalTo: self.labelView.leadingAnchor, constant: 16),
            self.titleLabel.trailingAnchor.constraint(equalTo: self.labelView.trailingAnchor, constant: -16),
            self.titleLabel.centerYAnchor.constraint(equalTo: self.labelView.centerYAnchor)
        ])
    }
}
