//
//  OpenStatsButton.swift
//  Sportsbook
//
//  Created by Ruben Roques on 18/09/2024.
//
import UIKit

class OpenStatsButton: UIView {
    
    var openStatsWidgetFullscreenAction: () -> () = { }
    
    private let shadowBackgroundView = UIView()
    private let button = UIButton()
    private let statsImage = UIImage(named: "open_stats_icon")?.withRenderingMode(.alwaysTemplate)
    
    init() {
        super.init(frame: .zero)
        self.setupSubviews()
        
        self.setupWithTheme()
    }
    
    @available(iOS, unavailable)
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setupSubviews() {
        self.translatesAutoresizingMaskIntoConstraints = false
        
        
        self.button.addTarget(self, action: #selector(self.openStatsWidgetFullscreen), for: .primaryActionTriggered)
        self.button.translatesAutoresizingMaskIntoConstraints = false
        self.button.setTitle(localized("view_stats"), for: .normal)
        
        self.button.setImage(self.statsImage, for: .normal)
        
        self.button.titleLabel?.font = AppFont.with(type: .semibold, size: 11)
        
        self.button.layer.cornerRadius = CornerRadius.button
        self.button.layer.masksToBounds = true
        
        self.button.setInsets(forContentPadding: UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8), imageTitlePadding: 4)

        self.shadowBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        
        self.shadowBackgroundView.layer.cornerRadius = CornerRadius.button
        self.shadowBackgroundView.layer.masksToBounds = true
        
        self.addSubview(self.shadowBackgroundView)
        self.addSubview(self.button)
        
        NSLayoutConstraint.activate([
            self.centerXAnchor.constraint(equalTo: self.button.centerXAnchor),
            self.centerYAnchor.constraint(equalTo: self.button.centerYAnchor, constant: 3),
            
            self.button.heightAnchor.constraint(equalToConstant: 23),
            
            self.shadowBackgroundView.leadingAnchor.constraint(equalTo: self.button.leadingAnchor),
            self.shadowBackgroundView.trailingAnchor.constraint(equalTo: self.button.trailingAnchor),
            self.shadowBackgroundView.topAnchor.constraint(equalTo: self.button.topAnchor),
            self.shadowBackgroundView.bottomAnchor.constraint(equalTo: self.button.bottomAnchor, constant: 2),
        ])
    }
    
    @objc func openStatsWidgetFullscreen() {
        self.openStatsWidgetFullscreenAction()
    }
    
    func setupWithTheme() {
        self.shadowBackgroundView.backgroundColor = UIColor.App.highlightPrimary
        
        self.button.imageView?.setTintColor(color: UIColor.App.textPrimary)
        self.button.tintColor = UIColor.App.textPrimary
        
        self.button.setTitleColor(UIColor.App.textPrimary, for: .normal)
        
        self.button.setBackgroundColor(UIColor.App.backgroundBorder, for: .normal)
        self.button.backgroundColor = .clear
    }
    
}
