//
//  ListBlockView.swift
//  Sportsbook
//
//  Created by André Lascas on 13/03/2025.
//

import UIKit

class ListBlockView: UIView {

    // MARK: Private properties
    private lazy var iconImageView: UIImageView = Self.createIconImageView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var subtitleLabel: UILabel = Self.createSubtitleLabel()

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
        
        self.iconImageView.backgroundColor = .clear
        
        self.titleLabel.textColor = UIColor.App.highlightPrimary
        
        self.subtitleLabel.textColor = UIColor.App.textPrimary
    }
    
    // MARK: Functions
    func configure(iconName: String, title: String, subtitle: String) {
        
        self.iconImageView.image = UIImage(named: iconName)
        
        self.titleLabel.text = title
        
        self.subtitleLabel.text = subtitle
    }

}

extension ListBlockView {
    
    private static func createIconImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = nil
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }
    
    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Title"
        label.font = AppFont.with(type: .semibold, size: 14)
        label.textAlignment = .left
        return label
    }
    
    private static func createSubtitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Subtitle"
        label.font = AppFont.with(type: .regular, size: 12)
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }
    
    func setupSubviews() {
        
        self.addSubview(self.iconImageView)
        self.addSubview(self.titleLabel)
        self.addSubview(self.subtitleLabel)
        
        self.initConstraints()
    }
    
    func initConstraints() {
        
        NSLayoutConstraint.activate([
            
            self.iconImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15),
            self.iconImageView.widthAnchor.constraint(equalToConstant: 30),
            self.iconImageView.heightAnchor.constraint(equalToConstant: 30),
            self.iconImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            
            self.titleLabel.leadingAnchor.constraint(equalTo: self.iconImageView.trailingAnchor, constant: 10),
            self.titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -15),
            self.titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 5),
            
            self.subtitleLabel.leadingAnchor.constraint(equalTo: self.iconImageView.trailingAnchor, constant: 10),
            self.subtitleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -15),
            self.subtitleLabel.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 10),
            self.subtitleLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5)
        ])
    }
}
