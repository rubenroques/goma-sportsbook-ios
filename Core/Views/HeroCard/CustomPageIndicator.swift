//
//  CustomPageIndicator.swift
//  Sportsbook
//
//  Created by André Lascas on 08/08/2024.
//

import UIKit

class CustomPageIndicator: UIView {

    private lazy var baseView: UIView = Self.createBaseView()
    private lazy var loadingView: UIView = Self.createLoadingView()

    var isActive: Bool = false {
        didSet {
            
            if isActive {
                self.startLoadingAnimation()
            }
            else {
                self.stopLoadingAnimation()
            }
        }
    }
    
    var pageNumber: Int = 0
    
    var indicatorWidth: CGFloat = 34.0
    var indicatorHeight: CGFloat = 5.0
    
    var didTap: ((Int) -> Void)? // Closure to handle tap

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupWithTheme()
        self.setupSubviews()
        self.commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupWithTheme()
        self.setupSubviews()
        self.commonInit()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.baseView.layer.cornerRadius = 2.5
    }
    
    private func setupWithTheme() {
        
        self.baseView.backgroundColor = .gray
        
        self.loadingView.backgroundColor = .gray
    }
    
    private func commonInit() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapIndicator))
                self.addGestureRecognizer(tapGesture)
        
    }
    
    private func startLoadingAnimation() {
        self.loadingView.frame.size.width = 0
        self.loadingView.backgroundColor = UIColor.App.highlightPrimary

        UIView.animate(withDuration: 5.0, animations: {
            self.loadingView.frame.size.width = self.indicatorWidth
        })
    }
    
    private func stopLoadingAnimation() {
        self.loadingView.backgroundColor = .gray

    }
    
    @objc private func didTapIndicator() {
        self.stopLoadingAnimation()
        didTap?(self.pageNumber)
    }
}

extension CustomPageIndicator {
    
    private static func createBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        return view
    }
    
    private static func createLoadingView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private func setupSubviews() {
        
        self.addSubview(self.baseView)
        
        self.baseView.addSubview(self.loadingView)

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
            self.baseView.widthAnchor.constraint(equalToConstant: self.indicatorWidth),
            self.baseView.heightAnchor.constraint(equalToConstant: self.indicatorHeight),
            
            self.loadingView.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor),
            self.loadingView.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor),
            self.loadingView.topAnchor.constraint(equalTo: self.baseView.topAnchor),
            self.loadingView.bottomAnchor.constraint(equalTo: self.baseView.bottomAnchor),
        ])
    }
}
