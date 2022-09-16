//
//  UserRankingPositionTableViewCell.swift
//  Sportsbook
//
//  Created by Ruben Roques on 07/09/2022.
//

import Foundation
import UIKit

class UserRankingPositionTableViewCell: UITableViewCell {
    
    var tapAction: () -> Void = { }
    var swipeViewAction: () -> Void = { }
    
    // MARK: Private Properties
    private lazy var baseView: UIView = Self.createBaseView()
    
    private lazy var positionBaseView: UIView = Self.createPositionBaseView()
    private lazy var positionLabel: UILabel = Self.createPositionLabel()
    
    private lazy var iconBaseView: UIView = Self.createIconBaseView()
    private lazy var iconImageView: UIImageView = Self.createIconImageView()
    
    private lazy var usernameLabel: UILabel = Self.createUsernameLabel()
    
    private lazy var oddValueBaseView: UIView = Self.createOddValueBaseView()
    private lazy var oddValueLabel: UILabel = Self.createOddValueLabel()
    
    private lazy var swipeBaseView: UIView = Self.createSwipeBaseView()
    private lazy var swipeLabel: UILabel = Self.createSwipeLabel()
    
    private var baseViewInitialCenter: CGPoint = .zero

    var viewModel: RankingCellViewModel?
    
    // MARK: Lifetime and Cycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.setupSubviews()
        self.setupWithTheme()

        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.didPanBaseView(_:)))
        self.baseView.addGestureRecognizer(panGestureRecognizer)
        
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        self.positionBaseView.layer.cornerRadius = self.positionBaseView.frame.height / 2
        
        self.iconBaseView.layer.cornerRadius = self.iconBaseView.frame.height / 2
        self.iconImageView.layer.cornerRadius = self.iconImageView.frame.height / 2
    }
    
    func setupWithTheme() {
        
        self.backgroundColor = .clear
        self.backgroundView?.backgroundColor = .clear

        self.contentView.backgroundColor = .clear
        self.baseView.backgroundColor = UIColor.App.backgroundSecondary
        
        self.iconBaseView.backgroundColor = UIColor.App.highlightPrimary
        self.iconImageView.backgroundColor = UIColor.App.backgroundTertiary
        
        self.positionBaseView.backgroundColor = UIColor.App.highlightPrimary
        
        self.usernameLabel.textColor = UIColor.App.textPrimary
        self.positionLabel.textColor = UIColor.App.textPrimary
        
        self.oddValueBaseView.backgroundColor = UIColor.App.backgroundCards
        self.oddValueLabel.textColor = UIColor.App.textPrimary
        
        self.swipeBaseView.backgroundColor = UIColor.App.backgroundSecondary
        self.swipeLabel.textColor = UIColor.App.textSecondary
    }

    // MARK: Function
    func configure(viewModel: RankingCellViewModel) {

        self.viewModel = viewModel

        self.positionLabel.text = viewModel.getRanking()

        self.usernameLabel.text = viewModel.getUsername()

        self.oddValueLabel.text = viewModel.getRankingScore()
    }

    // MARK: Actions
    @objc func didPanBaseView(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .began:
            self.baseViewInitialCenter = self.baseView.center
        case .changed:
            let translation = sender.translation(in: self.contentView)
            baseView.center = CGPoint(x: baseViewInitialCenter.x + translation.x, y: self.baseView.center.y)
        default:
            break
        }
    }
    
}

extension UserRankingPositionTableViewCell {
    
    private static func createBaseView() -> UIView {
        let view = UIView()
        view.layer.cornerRadius = 6
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createIconBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createIconImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "my_account_profile_icon")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .black
        return imageView
    }

    private static func createUsernameLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "James"
        label.font = AppFont.with(type: .semibold, size: 14)
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }

    private static func createPositionBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createPositionLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "3"
        label.font = AppFont.with(type: .bold, size: 12)
        return label
    }
    
    private static func createOddValueBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 6
        return view
    }
    
    private static func createOddValueLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "22.5"
        label.font = AppFont.with(type: .bold, size: 14)
        return label
    }
    
    private static func createSwipeBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 6
        return view
    }
    
    private static func createSwipeLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Unfollow"
        label.numberOfLines = 2
        label.font = AppFont.with(type: .bold, size: 12)
        return label
    }

    private func setupSubviews() {

        self.contentView.addSubview(self.swipeBaseView)
        self.swipeBaseView.addSubview(self.swipeLabel)
        
        self.contentView.addSubview(self.baseView)
        
        self.baseView.addSubview(self.positionBaseView)
        self.positionBaseView.addSubview(self.positionLabel)
        
        self.baseView.addSubview(self.iconBaseView)
        self.iconBaseView.addSubview(self.iconImageView)
        
        self.baseView.addSubview(self.usernameLabel)
        
        self.baseView.addSubview(self.oddValueBaseView)
        self.oddValueBaseView.addSubview(self.oddValueLabel)
        
        self.initConstraints()
    }

    private func initConstraints() {

        NSLayoutConstraint.activate([
            self.contentView.heightAnchor.constraint(equalToConstant: 62)
        ])
        
        NSLayoutConstraint.activate([
            self.swipeBaseView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -14),
            self.swipeBaseView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 4),
            self.swipeBaseView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -4),
            
            self.swipeLabel.leadingAnchor.constraint(equalTo: self.swipeBaseView.leadingAnchor, constant: 8),
            self.swipeLabel.centerXAnchor.constraint(equalTo: self.swipeBaseView.centerXAnchor),
            self.swipeLabel.centerYAnchor.constraint(equalTo: self.swipeBaseView.centerYAnchor),
        ])
        
        NSLayoutConstraint.activate([
            self.baseView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 14),
            self.baseView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -14),
            self.baseView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 4),
            self.baseView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -4),
        ])
        
        NSLayoutConstraint.activate([
            self.positionBaseView.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor, constant: 12),
            self.positionBaseView.centerYAnchor.constraint(equalTo: self.baseView.centerYAnchor),
            
            self.positionBaseView.widthAnchor.constraint(equalTo: self.positionBaseView.heightAnchor),
            self.positionBaseView.widthAnchor.constraint(equalToConstant: 18),
            
            self.positionLabel.centerYAnchor.constraint(equalTo: self.positionBaseView.centerYAnchor, constant: 0.5),
            self.positionLabel.centerXAnchor.constraint(equalTo: self.positionBaseView.centerXAnchor),
        ])
        
        NSLayoutConstraint.activate([
            self.iconBaseView.leadingAnchor.constraint(equalTo: self.positionBaseView.trailingAnchor, constant: 9),
            self.iconBaseView.centerYAnchor.constraint(equalTo: self.baseView.centerYAnchor),
            
            self.iconBaseView.widthAnchor.constraint(equalTo: self.iconBaseView.heightAnchor),
            self.iconBaseView.widthAnchor.constraint(equalToConstant: 34),
            
            self.iconImageView.widthAnchor.constraint(equalTo: self.iconImageView.heightAnchor),
            self.iconImageView.widthAnchor.constraint(equalToConstant: 30),
            
            self.iconImageView.centerYAnchor.constraint(equalTo: self.iconBaseView.centerYAnchor),
            self.iconImageView.centerXAnchor.constraint(equalTo: self.iconBaseView.centerXAnchor),
        ])
        
        NSLayoutConstraint.activate([
            self.usernameLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            self.usernameLabel.leadingAnchor.constraint(equalTo: self.iconBaseView.trailingAnchor, constant: 9),
            self.usernameLabel.trailingAnchor.constraint(equalTo: self.oddValueBaseView.leadingAnchor, constant: -6),
        ])
        
        NSLayoutConstraint.activate([
            self.oddValueBaseView.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor, constant: -12),
            self.oddValueBaseView.centerYAnchor.constraint(equalTo: self.baseView.centerYAnchor),
            self.oddValueBaseView.heightAnchor.constraint(equalToConstant: 25),
            
            self.oddValueLabel.centerXAnchor.constraint(equalTo: self.oddValueBaseView.centerXAnchor),
            self.oddValueLabel.centerYAnchor.constraint(equalTo: self.oddValueBaseView.centerYAnchor),
            
            self.oddValueLabel.leadingAnchor.constraint(equalTo: self.oddValueBaseView.leadingAnchor, constant: 6),
        ])
        
    }

}
