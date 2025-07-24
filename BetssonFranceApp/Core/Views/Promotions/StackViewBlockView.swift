//
//  StackViewBlockView.swift
//  Sportsbook
//
//  Created by André Lascas on 13/03/2025.
//

import UIKit

class StackViewBlockView: UIView {

    // MARK: Private properties
    private lazy var stackView: UIStackView = Self.createStackView()

    
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
        
        self.stackView.layer.cornerRadius = CornerRadius.button
    }
    
    func setupWithTheme() {
        self.backgroundColor = .clear

        self.stackView.backgroundColor = UIColor.App.backgroundSecondary
    }

    // MARK: Functions
    func configure(views: [UIView]) {
        
        for view in views {
            self.stackView.addArrangedSubview(view)
        }
        
        self.stackView.setNeedsLayout()
        self.stackView.layoutIfNeeded()
    }
}

extension StackViewBlockView {
    
    private static func createStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 0
        return stackView
    }
    
    func setupSubviews() {
        
        self.addSubview(self.stackView)
        
        self.initConstraints()
    }
    
    func initConstraints() {
        
        NSLayoutConstraint.activate([
            self.stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.stackView.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
            self.stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10)
        ])
    }
}
