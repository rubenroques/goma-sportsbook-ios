//
//  MakeYourBetTableViewCell.swift
//  Sportsbook
//
//  Created by Ruben Roques on 02/06/2023.
//

import Foundation
import UIKit

class MakeYourBetTableViewCell: UITableViewCell {

    var didTapCellAction: (() -> Void) = { }

    private let cellHeight: CGFloat = 130.0
    private var aspectRatio: CGFloat = 1.0

    private lazy var baseView: UIView = Self.createBaseView()
    private lazy var swipeImageView: UIImageView = Self.createImageView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.setupSubviews()
        self.setupWithTheme()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapCell))
        self.addGestureRecognizer(tapGesture)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.setupWithTheme()
    }

    func setupWithTheme() {
        self.backgroundColor = .clear
        self.backgroundView?.backgroundColor = .clear
        self.contentView.backgroundColor = .clear

//        self.baseView.layer.borderWidth = 1
//        self.baseView.layer.borderColor = UIColor.App.highlightSecondary.cgColor

        self.baseView.backgroundColor = .clear
        self.swipeImageView.backgroundColor = .clear
        // self.titleLabel.textColor = UIColor.App.textPrimary
    }

    @objc func didTapCell() {
        self.didTapCellAction()
    }

}

extension MakeYourBetTableViewCell {

    private static func createBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        return view
    }

    private static func createImageView() -> UIImageView {
        let view = UIImageView()
        view.image = UIImage(named: "combi_express_euro_banner")
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
        view.backgroundColor = .clear
        view.layer.cornerRadius = 7
        view.layer.masksToBounds = true
        return view
    }

    private func setupSubviews() {
        // Add subviews to self.view or each other
        self.contentView.addSubview(self.baseView)

        self.baseView.addSubview(self.swipeImageView)

        if let swipeImage = self.swipeImageView.image {
            self.aspectRatio = swipeImage.size.width / swipeImage.size.height
        }
        
        // Initialize constraints
        self.initConstraints()
    }

    private func initConstraints() {
        NSLayoutConstraint.activate([
             
            self.baseView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 0),
            self.baseView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: 0),
            self.baseView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 0),
            self.baseView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 0),

            self.swipeImageView.topAnchor.constraint(equalTo: self.baseView.topAnchor, constant: 20),
            self.swipeImageView.bottomAnchor.constraint(equalTo: self.baseView.bottomAnchor, constant: -20),
            self.swipeImageView.centerXAnchor.constraint(equalTo: self.baseView.centerXAnchor),
            self.swipeImageView.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor, constant: 18),
        ])
    }

}
