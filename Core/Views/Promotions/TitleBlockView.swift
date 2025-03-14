//
//  TitleBlockView.swift
//  Sportsbook
//
//  Created by André Lascas on 12/03/2025.
//

import UIKit

class TitleBlockView: UIView {

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
        
        self.titleLabel.textColor = UIColor.App.highlightPrimary
    }
    
    // MARK: Functions
    func configure(title: String) {
        self.titleLabel.text = title
    }
}

extension TitleBlockView {
    
    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.font = AppFont.with(type: .bold, size: 18)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
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
