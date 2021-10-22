//
//  CompetitionFilterHeaderView.swift
//  Sportsbook
//
//  Created by Ruben Roques on 19/10/2021.
//

import UIKit

class CompetitionFilterHeaderView: UITableViewHeaderFooterView {

    private var baseView: UIView = {
        var baseView  = UIView()
        baseView.translatesAutoresizingMaskIntoConstraints = false
        return baseView
    }()

    private var titleLabel: UILabel = {
        var label  = UILabel()
        label.font = AppFont.with(type: .bold, size: 16)
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private var arrowImageView: UIImageView = {
        var imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    var isExpanded: Bool = true

    var viewModel: CompetitionFilterSectionViewModel? {
        didSet {
            self.isExpanded = self.viewModel?.isExpanded ?? false
            self.titleLabel.text = self.viewModel?.name ?? ""
        }
    }

    var delegate: CollapsibleTableViewHeaderDelegate?

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
    
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapHeader)))

        self.setupSubviews()
        self.setupWithTheme()
    }

    @available(iOS, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func tapHeader() {

        guard let viewModel = viewModel else {
            return
        }

        if self.isExpanded {
            self.isExpanded = false
            delegate?.didCollapseSection(section: viewModel.sectionIndex)
        }
        else {
            self.isExpanded = true
            delegate?.didExpandSection(section: viewModel.sectionIndex)
        }

        self.setNeedsLayout()
        self.layoutIfNeeded()
     }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.isExpanded = false
        self.viewModel = nil
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if self.isExpanded {
            baseView.layer.mask = nil
            baseView.roundCorners(corners: [.topLeft, .topRight], radius: 5)
            arrowImageView.image = UIImage(named: "arrow_up_icon")
        }
        else {
            baseView.layer.mask = nil
            baseView.roundCorners(corners: [.topLeft, .topRight, .bottomLeft, .bottomRight], radius: 5)
            arrowImageView.image = UIImage(named: "arrow_down_icon")
        }
    }

    func setupSubviews() {

        arrowImageView.contentMode = .scaleAspectFit
        arrowImageView.image = UIImage(named: "arrow_down_icon")

        self.addSubview(baseView)
        baseView.addSubview(titleLabel)
        baseView.addSubview(arrowImageView)

        NSLayoutConstraint.activate([
            self.leadingAnchor.constraint(equalTo: baseView.leadingAnchor, constant: -26),
            self.trailingAnchor.constraint(equalTo: baseView.trailingAnchor, constant: 26),
            self.topAnchor.constraint(equalTo: baseView.topAnchor),
            self.bottomAnchor.constraint(equalTo: baseView.bottomAnchor),

            baseView.heightAnchor.constraint(greaterThanOrEqualToConstant: 56),

            baseView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor, constant: -20),

            baseView.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor, constant: -1),
            baseView.bottomAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),

            titleLabel.trailingAnchor.constraint(equalTo: arrowImageView.leadingAnchor, constant: -6),

            arrowImageView.widthAnchor.constraint(equalToConstant: 14),
            arrowImageView.widthAnchor.constraint(equalTo: arrowImageView.heightAnchor),
            arrowImageView.centerYAnchor.constraint(equalTo: baseView.centerYAnchor, constant: 1),
            arrowImageView.trailingAnchor.constraint(equalTo: baseView.trailingAnchor, constant: -20),

        ])
    }

    func setupWithTheme() {
        self.backgroundColor = .clear
        self.backgroundView?.backgroundColor = .clear
        self.contentView.backgroundColor = .clear

        baseView.backgroundColor = UIColor.App.secondaryBackground
        titleLabel.textColor = UIColor.App.headingMain
        arrowImageView.backgroundColor = .clear
    }

}


protocol CollapsibleTableViewHeaderDelegate: AnyObject {
    func didCollapseSection(section: Int)
    func didExpandSection(section: Int)
}

