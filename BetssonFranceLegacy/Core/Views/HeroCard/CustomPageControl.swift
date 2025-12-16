//
//  CustomPageControl.swift
//  Sportsbook
//
//  Created by André Lascas on 07/08/2024.
//

import UIKit

class CustomPageControl: UIView {
    
    private lazy var baseView: UIView = Self.createBaseView()
    private lazy var stackView: UIStackView = Self.createStackView()
    
    var numberOfPages: Int = 0 {
        didSet {
            configureIndicators()
        }
    }
    
    var currentPage: Int = 0 {
        didSet {
            updateIndicators()
        }
    }
    
    var didTapIndicator: ((Int) -> Void)? // Closure to handle indicator tap in the parent
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupWithTheme()
        self.setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupWithTheme()
        self.setupSubviews()
    }
    
    private func setupWithTheme() {
        self.backgroundColor = .clear
        
        self.baseView.backgroundColor = .clear
        
        self.stackView.backgroundColor = .clear
    }
    
    private func configureIndicators() {
        self.stackView.arrangedSubviews.forEach { $0.removeFromSuperview()
        }
        
        for i in 0..<self.numberOfPages {
            let indicator = CustomPageIndicator()
            indicator.pageNumber = i
            
            indicator.didTap = { [weak self] page in
                self?.didTapIndicator?(page) // Notify the tap to parent view
            }
            
            stackView.addArrangedSubview(indicator)
        }
        
        self.updateIndicators()
    }
    
    private func updateIndicators() {
        for (index, view) in self.stackView.arrangedSubviews.enumerated() {
            
            if let pageIndicator = view as? CustomPageIndicator {
                
                if index == self.currentPage {
                    pageIndicator.isActive = true
                } else {
                    pageIndicator.isActive = false
                }
            }
        }
        
    }
}

extension CustomPageControl {
    
    private static func createBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        return stackView
    }
    
    private func setupSubviews() {
        
        self.addSubview(self.baseView)
        
        self.baseView.addSubview(self.stackView)

        self.initConstraints()
        
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    
    private func initConstraints() {
        
        NSLayoutConstraint.activate([
            
            self.baseView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.baseView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.baseView.topAnchor.constraint(equalTo: self.topAnchor),
            self.baseView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            self.baseView.heightAnchor.constraint(equalToConstant: 30),
            
            self.stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            self.stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            self.stackView.centerYAnchor.constraint(equalTo: self.baseView.centerYAnchor),
            self.stackView.heightAnchor.constraint(equalToConstant: 5)
        ])
    }
}
