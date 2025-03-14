//
//  GradientHeaderView.swift
//  Sportsbook
//
//  Created by André Lascas on 12/03/2025.
//

import UIKit

class GradientHeaderView: UIView {

    // MARK: Private properties
    private lazy var gradientView: GradientView = Self.createGradientView()
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
        
        self.gradientView.startPoint = CGPoint(x: 0.0, y: 1.0)
        self.gradientView.endPoint = CGPoint(x: 1.0, y: 0.0)
    }
    
    func setupWithTheme() {
        self.backgroundColor = .clear

        self.gradientView.colors = [(UIColor.App.highlightPrimary, NSNumber(0.0)),
                                    (UIColor.App.highlightSecondary, NSNumber(1.0))]
        
        self.titleLabel.textColor = UIColor.App.buttonTextPrimary
    }
    
    // MARK: Functions
    func configure(title: String) {
        self.titleLabel.text = title
    }
}

extension GradientHeaderView {
    
    private static func createGradientView() -> GradientView {
        let view = GradientView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.font = AppFont.with(type: .bold, size: 24)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    func setupSubviews() {
        
        self.addSubview(self.gradientView)
        
        self.gradientView.addSubview(self.titleLabel)

        self.initConstraints()
    }
    
    func initConstraints() {
        
        NSLayoutConstraint.activate([
            self.gradientView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.gradientView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.gradientView.topAnchor.constraint(equalTo: self.topAnchor),
            self.gradientView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            self.gradientView.heightAnchor.constraint(equalToConstant: 208),
            
            self.titleLabel.leadingAnchor.constraint(equalTo: self.gradientView.leadingAnchor, constant: 15),
            self.titleLabel.trailingAnchor.constraint(equalTo: self.gradientView.trailingAnchor, constant: -15),
            self.titleLabel.centerYAnchor.constraint(equalTo: self.gradientView.centerYAnchor)
        ])
    }
}
