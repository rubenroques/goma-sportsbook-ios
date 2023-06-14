//
//  StoriesItemCollectionViewCell.swift
//  Sportsbook
//
//  Created by Ruben Roques on 05/06/2023.
//

import Foundation
import UIKit

struct StoriesItemCellViewModel {

    var imageName: String
    var title: String
    var read: Bool

    init(imageName: String, title: String, read: Bool) {
        self.imageName = imageName
        self.title = title
        self.read = read
    }

}

class StoriesItemCollectionViewCell: UICollectionViewCell {

    var selectedItemAction: (StoriesItemCellViewModel) -> Void = { _ in }

    private let backgroundGradientView: UIView = {
        let backgroundGradientView = UIView()
        backgroundGradientView.layer.cornerRadius = 11
        backgroundGradientView.layer.masksToBounds = true
        backgroundGradientView.translatesAutoresizingMaskIntoConstraints = false
        backgroundGradientView.clipsToBounds = true
        return backgroundGradientView
    }()

    private let gradientBorderView: UIView = {
        let gradientBorderView = UIView()
        gradientBorderView.translatesAutoresizingMaskIntoConstraints = false
        gradientBorderView.layer.cornerRadius = 11
        gradientBorderView.layer.masksToBounds = true
        gradientBorderView.layer.borderWidth = 2
        gradientBorderView.layer.borderColor = UIColor.App.highlightPrimary.cgColor
        return gradientBorderView
    }()

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()

    private let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.textAlignment = .center
        label.font = AppFont.with(type: .semibold, size: 11)
        return label
    }()

    private var viewModel: StoriesItemCellViewModel?

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.commonInit()
    }

    private func commonInit() {

        let nextTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapItemView))
        self.addGestureRecognizer(nextTapGesture)

        self.setupViews()
    }

    private func setupViews() {

        self.backgroundColor = .clear
        self.backgroundView?.backgroundColor = .clear
        self.contentView.backgroundColor = .clear

        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor(hex: 0xF1681E, alpha: 1.0).cgColor,
            UIColor(hex: 0xF8C633, alpha: 1.0).cgColor,
        ]

        gradientLayer.startPoint = CGPoint(x: 0.0, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 0.9, y: 0.0)
        gradientLayer.frame = bounds

        self.addSubview(self.backgroundGradientView)
        self.addSubview(self.gradientBorderView)

        self.backgroundGradientView.layer.addSublayer(gradientLayer)

        self.addSubview(self.imageView)
        self.addSubview(self.label)

        NSLayoutConstraint.activate([
            self.backgroundGradientView.leadingAnchor.constraint(equalTo: self.gradientBorderView.leadingAnchor),
            self.backgroundGradientView.trailingAnchor.constraint(equalTo: self.gradientBorderView.trailingAnchor),
            self.backgroundGradientView.topAnchor.constraint(equalTo: self.gradientBorderView.topAnchor),
            self.backgroundGradientView.bottomAnchor.constraint(equalTo: self.gradientBorderView.bottomAnchor),

            self.backgroundGradientView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            self.backgroundGradientView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            self.backgroundGradientView.widthAnchor.constraint(equalToConstant: 82),
            self.backgroundGradientView.heightAnchor.constraint(equalToConstant: 102),

            self.imageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            self.imageView.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -4),
            self.imageView.widthAnchor.constraint(equalToConstant: 60),
            self.imageView.heightAnchor.constraint(equalToConstant: 60),

            self.label.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            self.label.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 2),
            self.label.topAnchor.constraint(equalTo: self.imageView.bottomAnchor, constant: 3),
            self.label.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -3),
        ])
    }

    // Configure the cell with your data
    func configureWithViewModel(viewModel: StoriesItemCellViewModel) {
        self.viewModel = viewModel

        self.imageView.image = UIImage(named: viewModel.imageName)
        self.label.text = viewModel.title

        self.imageView.image = UIImage(named: "avatar3")
        self.label.text = "Promotions"

        if viewModel.read {
            self.gradientBorderView.isHidden = false
            self.backgroundGradientView.isHidden = true
            self.label.textColor = UIColor.App.textPrimary
        }
        else {
            self.gradientBorderView.isHidden = true
            self.backgroundGradientView.isHidden = false
            self.label.textColor = UIColor.App.buttonTextPrimary
        }
    }

    @objc func didTapItemView() {
        if let viewModel = self.viewModel {
            self.selectedItemAction(viewModel)
        }
    }

}
