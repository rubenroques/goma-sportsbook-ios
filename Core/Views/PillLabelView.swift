//
//  PillLabelView.swift
//  Sportsbook
//
//  Created by Ruben Roques on 05/04/2024.
//

import Foundation
import UIKit

class PillLabelView: UIView {

    private lazy var borderView: UIView = {
        var borderView = UIView()
        borderView.translatesAutoresizingMaskIntoConstraints = false
        borderView.backgroundColor = .clear
        return borderView
    }()
    
    private lazy var lineView: FadingView = {
        var lineView = FadingView()
        lineView.translatesAutoresizingMaskIntoConstraints = false
        lineView.backgroundColor = UIColor.App.separatorLineSecondary
        lineView.colors = [.black, .clear]
        lineView.startPoint = CGPoint(x: 0.0, y: 0.5)
        lineView.endPoint = CGPoint(x: 1.0, y: 0.5)
        lineView.fadeLocations = [0.0, 1.0]
        return lineView
    }()
    
    private lazy var textLabel: UILabel = {
        var textLabel = UILabel()
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.textAlignment = .center
        textLabel.backgroundColor = .clear
        textLabel.font = UIFont.systemFont(ofSize: 10)
        return textLabel
    }()

    var title: String = "" {
        didSet {
            self.textLabel.text = self.title
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        self.backgroundColor = .clear
        self.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(self.borderView)
        
        self.addSubview(self.lineView)
        
        self.borderView.addSubview(self.textLabel)
        
        NSLayoutConstraint.activate([
            self.borderView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 1),
            self.borderView.topAnchor.constraint(equalTo: self.topAnchor, constant: 1),
            self.borderView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -1),
            
            self.borderView.trailingAnchor.constraint(equalTo: self.lineView.leadingAnchor, constant: 0),
            
            self.lineView.widthAnchor.constraint(equalToConstant: 19),
            self.lineView.heightAnchor.constraint(equalToConstant: 1),
            self.lineView.centerYAnchor.constraint(equalTo: self.borderView.centerYAnchor),
            self.lineView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            
            self.textLabel.topAnchor.constraint(equalTo: self.borderView.topAnchor, constant: 2),
            self.textLabel.bottomAnchor.constraint(equalTo: self.borderView.bottomAnchor, constant: -2),
            self.textLabel.leadingAnchor.constraint(equalTo: self.borderView.leadingAnchor, constant: 6),
            self.textLabel.trailingAnchor.constraint(equalTo: self.borderView.trailingAnchor, constant: -6),
        ])
        
        self.textLabel.text = ""
        
        self.borderView.layer.borderWidth = 1
        
        self.borderView.layer.borderColor = UIColor.App.separatorLineSecondary.cgColor
        self.textLabel.textColor = UIColor.App.textSecondary
    }
    
    override var intrinsicContentSize: CGSize {
        let borderViewSize = self.borderView.intrinsicContentSize
        let lineSize = self.lineView.intrinsicContentSize
        return CGSize(width: borderViewSize.width + lineSize.width + 4, height: borderViewSize.height + 6)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.borderView.layer.cornerRadius = self.borderView.bounds.height / 2
    }
    
    
    func setupWithTheme() {

        self.borderView.layer.borderColor = UIColor.App.separatorLineSecondary.cgColor
        self.textLabel.textColor = UIColor.App.textSecondary
        self.lineView.backgroundColor = UIColor.App.separatorLineSecondary
        self.borderView.backgroundColor = .clear
        self.textLabel.backgroundColor = .clear
        
    }
    
}
