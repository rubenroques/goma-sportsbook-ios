//
//  LetterCollectionViewCell.swift
//  MultiBet
//
//  Created by André Lascas on 07/11/2024.
//

import UIKit

class LetterCollectionViewCell: UICollectionViewCell {
    
    // MARK: Private Properties
    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var letterLabel: UILabel = Self.createLetterLabel()
    
    var didTapCell: ( () -> Void)?

    // MARK: - Lifetime and Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)

        self.setupSubviews()
        self.setupWithTheme()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))

        self.containerView.addGestureRecognizer(tapGesture)
        self.containerView.isUserInteractionEnabled = true
        
        tapGesture.cancelsTouchesInView = false
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.letterLabel.text = ""
    }

    // MARK: - Theme and Layout
    override func layoutSubviews() {
        super.layoutSubviews()

        self.contentView.layoutIfNeeded()
        
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    func setupWithTheme() {

        self.contentView.backgroundColor = .clear

        self.letterLabel.textColor = UIColor.App.highlightSecondary
    }
    
    // MARK: Function

    func configure(title: String) {
        self.letterLabel.text = title
    }
    
    @objc private func handleTapGesture(_ sender: UITapGestureRecognizer) {
        
        print("Tapped \(String(describing: self.letterLabel.text))")
        
    }
}

extension LetterCollectionViewCell {

    private static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = CornerRadius.view
        view.layer.masksToBounds = true
        return view
    }

    private static func createLetterLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = ""
        label.font = AppFont.with(type: .semibold, size: 11)
        label.textAlignment = .center
        return label
    }

    private func setupSubviews() {

        self.contentView.addSubview(self.containerView)

        self.containerView.addSubview(self.letterLabel)

        self.initConstraints()
    }

    private func initConstraints() {
        
        NSLayoutConstraint.activate([
            self.containerView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            self.containerView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            self.containerView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            self.containerView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
            self.containerView.widthAnchor.constraint(equalToConstant: 15),
            self.containerView.heightAnchor.constraint(equalTo: self.containerView.widthAnchor),
            
            self.letterLabel.centerXAnchor.constraint(equalTo: self.containerView.centerXAnchor),
            self.letterLabel.centerYAnchor.constraint(equalTo: self.containerView.centerYAnchor)
        ])

    }
}
