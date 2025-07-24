//
//  VideoPreviewCollectionViewCell.swift
//  Sportsbook
//
//  Created by Ruben Roques on 05/05/2022.
//

import UIKit

class VideoPreviewCellViewModel {

    var videoItemFeedContent: VideoItemFeedContent

    init(videoItemFeedContent: VideoItemFeedContent) {
        self.videoItemFeedContent = videoItemFeedContent
    }

    func imageURL() -> URL? {
        if let urlString = videoItemFeedContent.imageURL {
            return URL(string: urlString)
        }
        return nil
    }

    var title: String {
        self.videoItemFeedContent.title ?? ""
    }

    var subtitle: String {
        self.videoItemFeedContent.description ?? ""
    }

    var externalStreamURL: URL? {
        if let streamURLString = videoItemFeedContent.streamURL {
            return URL(string: streamURLString)
        }
        return nil
    }
}

class VideoPreviewCollectionViewCell: UICollectionViewCell {

    var didTapVideoPreviewCellAction: ((VideoPreviewCellViewModel) -> Void) = { _ in }

    private lazy var baseView: UIView = Self.createBaseView()

    private lazy var imageView: UIImageView = Self.createImageView()

    private lazy var bottomBaseView: UIView = Self.createBottomBaseView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var subtitleLabel: UILabel = Self.createSubtitleLabel()

    private var viewModel: VideoPreviewCellViewModel?

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.setupSubviews()
        self.setupWithTheme()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.didTapBaseView))
        self.baseView.addGestureRecognizer(tapGesture)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.setupWithTheme()

        self.imageView.kf.cancelDownloadTask()
        self.imageView.image = nil

        self.titleLabel.text = ""
        self.subtitleLabel.text = ""
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.setupWithTheme()
    }

    func setupWithTheme() {
        self.backgroundView?.backgroundColor = .clear
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear

        self.baseView.backgroundColor = UIColor.App.backgroundCards

        self.imageView.backgroundColor = UIColor.App.backgroundCards
        
        self.titleLabel.textColor = UIColor.App.textPrimary
        self.subtitleLabel.textColor = UIColor.App.textPrimary
    }

    func configure(withViewModel viewModel: VideoPreviewCellViewModel) {
        self.viewModel = viewModel

        if let url = viewModel.imageURL() {
            self.imageView.kf.setImage(with: url)
        }

        self.titleLabel.text = viewModel.subtitle
        self.subtitleLabel.text = viewModel.title
    }

    @objc private func didTapBaseView() {
        if let viewModel = self.viewModel {
            self.didTapVideoPreviewCellAction(viewModel)
        }
    }

}

extension VideoPreviewCollectionViewCell {

    private static func createBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        return view
    }

    private static func createImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.alpha = 0.85
        imageView.clipsToBounds = true
        return imageView
    }

    private static func createBottomBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createTitleLabel() -> UILabel {
        let titleLabel = UILabel()
        titleLabel.numberOfLines = 2
        titleLabel.textAlignment = .left
        titleLabel.text = ""
        titleLabel.font = AppFont.with(type: .bold, size: 13)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleLabel
    }

    private static func createSubtitleLabel() -> UILabel {
        let titleLabel = UILabel()
        titleLabel.numberOfLines = 1
        titleLabel.textAlignment = .left
        titleLabel.text = ""
        titleLabel.font = AppFont.with(type: .regular, size: 12)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleLabel
    }

    private func setupSubviews() {
        // Add subviews to self.view or each other
        self.contentView.addSubview(self.baseView)

        self.baseView.addSubview(self.imageView)
        self.baseView.addSubview(self.bottomBaseView)

        self.bottomBaseView.addSubview(self.titleLabel)
        self.bottomBaseView.addSubview(self.subtitleLabel)

        // Initialize constraints
        self.initConstraints()
    }

    private func initConstraints() {
        NSLayoutConstraint.activate([
            self.baseView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            self.baseView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            self.baseView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            self.baseView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),

            self.imageView.topAnchor.constraint(equalTo: self.baseView.topAnchor),
            self.imageView.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor),
            self.imageView.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor),
            self.imageView.bottomAnchor.constraint(equalTo: self.bottomBaseView.topAnchor),

            self.bottomBaseView.bottomAnchor.constraint(equalTo: self.baseView.bottomAnchor),
            self.bottomBaseView.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor),
            self.bottomBaseView.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor),
            self.bottomBaseView.heightAnchor.constraint(equalToConstant: 61),

            self.titleLabel.leadingAnchor.constraint(equalTo: self.bottomBaseView.leadingAnchor, constant: 12),
            self.titleLabel.trailingAnchor.constraint(equalTo: self.bottomBaseView.trailingAnchor, constant: -12),
            self.titleLabel.topAnchor.constraint(equalTo: self.bottomBaseView.topAnchor, constant: 8),
            self.titleLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 20),

            self.subtitleLabel.leadingAnchor.constraint(equalTo: self.bottomBaseView.leadingAnchor, constant: 12),
            self.subtitleLabel.trailingAnchor.constraint(equalTo: self.bottomBaseView.trailingAnchor, constant: -12),
            self.subtitleLabel.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 4),
            self.subtitleLabel.heightAnchor.constraint(equalToConstant: 18),
        ])

    }
}
