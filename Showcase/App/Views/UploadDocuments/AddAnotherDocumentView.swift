//
//  AddAnotherDocumentView.swift
//  Sportsbook
//
//  Created by André Lascas on 20/01/2023.
//

import UIKit
import Combine

class AddAnotherDocumentView: UIView {

    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var addAnotherBaseView: UIView = Self.createAddAnotherBaseView()
    private lazy var addAnotherView: UIView = Self.createAddAnotherView()
    private lazy var addAnotherTitleLabel: UILabel = Self.createAddAnotherTitleLabel()
    private lazy var addAnotherIconImageView: UIImageView = Self.createAddAnotherIconImageView()

    // MARK: Public Properties
    var shouldAddNewDocument: (() -> Void)?
    var shouldSelectFile: ((String) -> Void)?

    // MARK: - Lifetime and Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)

        self.commonInit()
        self.setupWithTheme()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.commonInit()
        self.setupWithTheme()
    }

    func commonInit() {

        self.setupSubviews()

        let tapAddAnother = UITapGestureRecognizer(target: self, action: #selector(self.tapAddAnotherAction))
        self.addAnotherBaseView.addGestureRecognizer(tapAddAnother)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

    }

    func setupWithTheme() {
        self.containerView.backgroundColor = UIColor.App.backgroundSecondary

        self.addAnotherBaseView.backgroundColor = .clear

        self.addAnotherView.backgroundColor = .clear

        self.addAnotherTitleLabel.textColor = UIColor.App.textSecondary

        self.addAnotherIconImageView.backgroundColor = .clear
    }

    // MARK: Action
    @objc func tapAddAnotherAction() {

        print("ADD ANOTHER")
        self.shouldAddNewDocument?()
    }
}

//
// MARK: - Subviews Initialization and Setup
//
extension AddAnotherDocumentView {

    private static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createAddAnotherBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createAddAnotherView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createAddAnotherTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Add another"
        label.font = AppFont.with(type: .bold, size: 11)
        return label
    }

    private static func createAddAnotherIconImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "add_document_icon")
        return imageView
    }

    private func setupSubviews() {

        self.addSubview(self.containerView)

        self.containerView.addSubview(self.addAnotherBaseView)

        self.addAnotherBaseView.addSubview(self.addAnotherView)

        self.addAnotherView.addSubview(self.addAnotherTitleLabel)
        self.addAnotherView.addSubview(self.addAnotherIconImageView)

        self.initConstraints()

    }

    private func initConstraints() {

        NSLayoutConstraint.activate([
            self.containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.containerView.topAnchor.constraint(equalTo: self.topAnchor),
            self.containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor),

            self.addAnotherBaseView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
            self.addAnotherBaseView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor),
            self.addAnotherBaseView.topAnchor.constraint(equalTo: self.containerView.topAnchor),
            self.addAnotherBaseView.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor),
            self.addAnotherBaseView.heightAnchor.constraint(equalToConstant: 40),

            self.addAnotherView.centerXAnchor.constraint(equalTo: self.addAnotherBaseView.centerXAnchor),
            //self.addAnotherView.centerYAnchor.constraint(equalTo: self.addAnotherBaseView.centerYAnchor),
            self.addAnotherView.bottomAnchor.constraint(equalTo: self.addAnotherBaseView.bottomAnchor),

            self.addAnotherTitleLabel.leadingAnchor.constraint(equalTo: self.addAnotherView.leadingAnchor),
            self.addAnotherTitleLabel.topAnchor.constraint(equalTo: self.addAnotherView.topAnchor, constant: 10),
            self.addAnotherTitleLabel.bottomAnchor.constraint(equalTo: self.addAnotherView.bottomAnchor, constant: -5),

            self.addAnotherIconImageView.leadingAnchor.constraint(equalTo: self.addAnotherTitleLabel.trailingAnchor, constant: 5),
            self.addAnotherIconImageView.trailingAnchor.constraint(equalTo: self.addAnotherView.trailingAnchor),
            self.addAnotherIconImageView.widthAnchor.constraint(equalToConstant: 24),
            self.addAnotherIconImageView.heightAnchor.constraint(equalTo: self.addAnotherIconImageView.widthAnchor),
            self.addAnotherIconImageView.centerYAnchor.constraint(equalTo: self.addAnotherTitleLabel.centerYAnchor)
        ])
    }
}
