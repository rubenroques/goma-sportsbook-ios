//
//  ActionButtonBlockView.swift
//  Sportsbook
//
//  Created by André Lascas on 13/03/2025.
//

import UIKit

class ActionButtonBlockView: UIView {

    // MARK: Private properties
    private lazy var actionButton: UIButton = Self.createActionButton()
    
    // MARK: Public properties
    var actionName: String?
    var tappedActionButtonAction: ((String) -> Void)?

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
        
        self.actionButton.addTarget(self, action: #selector(didTapActionButton), for: .primaryActionTriggered)
    }
    
    // MARK: Layout and theme
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.actionButton.layer.cornerRadius = CornerRadius.button
    }
    
    func setupWithTheme() {
        self.backgroundColor = .clear
        
        self.actionButton.backgroundColor = UIColor.App.buttonBackgroundPrimary
        self.actionButton.setTitleColor(UIColor.App.buttonTextPrimary, for: .normal)
    }
    
    // MARK: Functions
    func configure(title: String, actionName: String) {
        self.actionButton.setTitle(title, for: .normal)
        
        self.actionName = actionName
    }
    
    // MARK: Actions
    @objc private func didTapActionButton() {
        if let actionName = self.actionName {
            self.tappedActionButtonAction?(actionName)
        }
    }

}

extension ActionButtonBlockView {
    
    private static func createActionButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("CTA", for: .normal)
        return button
    }
    
    func setupSubviews() {
        
        self.addSubview(self.actionButton)
        
        self.initConstraints()
    }
    
    func initConstraints() {
        
        NSLayoutConstraint.activate([
            
            self.actionButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15),
            self.actionButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -15),
            self.actionButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 5),
            self.actionButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5),
            self.actionButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
}

