//
//  RankingTypeTableHeaderView.swift
//  Sportsbook
//
//  Created by Ruben Roques on 07/09/2022.
//

import UIKit

class RankingTypeTableHeaderView: UITableViewHeaderFooterView {

    var tapAction: () -> Void = { }
    
    // MARK: Private Properties
    private lazy var buttonView: UIView = Self.createButtonView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()

    private lazy var dropDownImageView: UIImageView = Self.createDropDownImageView()
    
    // MARK: - Lifetime and Cycle
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)

        self.setupSubviews()
        self.setupWithTheme()
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapButtonView))
        self.buttonView.addGestureRecognizer(tapGestureRecognizer)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()

    }

    // MARK: - Layout and Theme
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.setupWithTheme()
    }

    func setupWithTheme() {
        self.titleLabel.textColor = UIColor.App.textPrimary

        self.contentView.backgroundColor = .clear
        self.buttonView.backgroundColor = .clear
        self.buttonView.layer.borderWidth = 0
        
        self.dropDownImageView.tintColor = UIColor.App.textPrimary
    }

    // MARK: Functions
    func configureWithTitle(_ title: String) {
        self.titleLabel.text = title

    }
    
    @objc func didTapButtonView() {
        self.tapAction()
    }
    
}

//
// MARK: Subviews initialization and setup
//
extension RankingTypeTableHeaderView {

    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.text = localized("empty_value")
        label.font = AppFont.with(type: .bold, size: 15)
        label.textAlignment = .left
        return label
    }

    private static func createButtonView() -> UIView {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createDropDownImageView() -> UIImageView {
        let imageView = UIImageView(image: UIImage(systemName: "arrowtriangle.down.fill"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }
    
    private func setupSubviews() {

        self.contentView.addSubview(self.buttonView)

        self.buttonView.addSubview(self.titleLabel)
        self.buttonView.addSubview(self.dropDownImageView)
        
        self.initConstraints()
    }

    private func initConstraints() {

        NSLayoutConstraint.activate([
            
            self.buttonView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 14),
            self.buttonView.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
            self.buttonView.heightAnchor.constraint(equalToConstant: 37),
            
            self.titleLabel.leadingAnchor.constraint(equalTo: self.buttonView.leadingAnchor, constant: 12),
            self.titleLabel.centerYAnchor.constraint(equalTo: self.buttonView.centerYAnchor),
            
            self.dropDownImageView.leadingAnchor.constraint(equalTo: self.titleLabel.trailingAnchor, constant: 4),
            
            self.dropDownImageView.centerYAnchor.constraint(equalTo: self.buttonView.centerYAnchor),
            self.dropDownImageView.widthAnchor.constraint(equalTo: self.dropDownImageView.heightAnchor),
            self.dropDownImageView.widthAnchor.constraint(equalToConstant: 14),
            self.dropDownImageView.trailingAnchor.constraint(equalTo: self.buttonView.trailingAnchor, constant: -14),
        ])
    }
}
