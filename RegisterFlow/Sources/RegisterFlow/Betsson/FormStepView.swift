//
//  FormStepView.swift
//  
//
//  Created by Ruben Roques on 16/01/2023.
//

import Foundation
import UIKit

public class FormStepView: UIView {

    lazy var contentView: UIView = Self.createContentView()
    lazy var stackView: UIStackView = Self.createStackView()

    lazy var headerView: UIView = Self.createHeaderView()
    lazy var titleLabel: UILabel = Self.createTitleLabel()

    public init() {
        super.init(frame: .zero)

        self.commonInit()
        self.setupWithTheme()
    }

    @available(iOS, unavailable)
    required public override init(frame: CGRect) {
        fatalError()
    }

    @available(iOS, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    private func commonInit() {
        self.setupSubviews()
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
    }

    func setupWithTheme() {
        self.backgroundColor = .black

        self.contentView.backgroundColor = .gray
    }

}

extension FormStepView {

    private static var headerHeight: CGFloat {
        return 90
    }

    private static func createHeaderView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.preferredFont(forTextStyle: .title1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    private static func createContentView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 24
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = .green
        return stackView
    }

    func setupSubviews() {

        self.initConstraints()
    }

    func initConstraints() {
        self.addSubview(self.contentView)

        self.contentView.addSubview(self.headerView)
        self.headerView.addSubview(self.titleLabel)

        self.contentView.addSubview(self.stackView)

        NSLayoutConstraint.activate([
            self.contentView.topAnchor.constraint(equalTo: self.topAnchor),
            self.contentView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.contentView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.contentView.bottomAnchor.constraint(equalTo: self.bottomAnchor),

            self.headerView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            self.headerView.heightAnchor.constraint(equalToConstant: Self.headerHeight),
            self.headerView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            self.headerView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),

            self.titleLabel.centerXAnchor.constraint(equalTo: self.headerView.centerXAnchor),
            self.titleLabel.centerYAnchor.constraint(equalTo: self.headerView.centerYAnchor),
            self.titleLabel.leadingAnchor.constraint(equalTo: self.headerView.leadingAnchor, constant: 34),
            self.titleLabel.topAnchor.constraint(equalTo: self.headerView.topAnchor, constant: 8),

            self.stackView.topAnchor.constraint(equalTo: self.headerView.bottomAnchor),
            self.stackView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 34),
            self.stackView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -34),
            self.stackView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -16),
        ])

    }

}

