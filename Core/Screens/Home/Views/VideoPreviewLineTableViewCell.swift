//
//  VideoPreviewLineTableViewCell.swift
//  Sportsbook
//
//  Created by Ruben Roques on 04/05/2022.
//

import UIKit

class VideoPreviewLineCellViewModel {

    var title: String?
    var videoItemFeedContents: [VideoItemFeedContent]
    var videoPreviewCellViewModelsCache: [Int: SuggestedBetViewModel] = [:]

    init(title: String?, videoItemFeedContents: [VideoItemFeedContent]) {
        self.videoItemFeedContents = videoItemFeedContents
        self.title = title
    }

    func numberOfItems() -> Int {
        return videoItemFeedContents.count
    }

    func viewModel(forIndex index: Int) -> VideoPreviewCellViewModel? {
        guard
            let videoItemFeedContent = self.videoItemFeedContents[safe: index]
        else {
            return nil
        }
        return VideoPreviewCellViewModel(videoItemFeedContent: videoItemFeedContent)
    }

    var titleSection: String {
        return (self.title ?? "").uppercased()
    }
}

class VideoPreviewLineTableViewCell: UITableViewCell {

    var didTapVideoPreviewLineCellAction: ((VideoPreviewCellViewModel) -> Void) = { _ in }

    private lazy var baseView: UIView = Self.createBaseView()
    private lazy var collectionView: UICollectionView = Self.createCollectionView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()

    private var viewModel: VideoPreviewLineCellViewModel?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.setupSubviews()
        self.setupWithTheme()

        self.collectionView.delegate = self
        self.collectionView.dataSource = self

        self.collectionView.register(VideoPreviewCollectionViewCell.self, forCellWithReuseIdentifier: VideoPreviewCollectionViewCell.identifier)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.collectionView.setContentOffset(CGPoint(x: -16, y: 0), animated: false)

        self.titleLabel.text = ""
        self.viewModel = nil
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.setupWithTheme()
    }

    func setupWithTheme() {
        self.backgroundColor = .clear
        self.backgroundView?.backgroundColor = .clear
        self.contentView.backgroundColor = UIColor.App.backgroundPrimary

        self.baseView.backgroundColor = UIColor.App.backgroundPrimary
        self.titleLabel.textColor = UIColor.App.textPrimary

        self.collectionView.backgroundView?.backgroundColor = UIColor.App.backgroundPrimary
        self.collectionView.backgroundColor = UIColor.App.backgroundPrimary
    }

    func configure(withViewModel viewModel: VideoPreviewLineCellViewModel) {
        self.viewModel = viewModel
        self.titleLabel.text = viewModel.titleSection
        self.reloadData()
    }

    func reloadData() {
        self.collectionView.reloadData()
    }

}

extension VideoPreviewLineTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel?.numberOfItems() ?? 0
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let cell = collectionView.dequeueCellType(VideoPreviewCollectionViewCell.self, indexPath: indexPath),
            let viewModel = self.viewModel?.viewModel(forIndex: indexPath.row)
        else {
            fatalError()
        }
        cell.configure(withViewModel: viewModel)
        cell.didTapVideoPreviewCellAction = { [weak self] viewModel in
            self?.didTapVideoPreviewLineCellAction(viewModel)
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let height = collectionView.frame.size.height - 16
        let width = height * (160/124)

        return CGSize(width: width, height: height)
    }

}

extension VideoPreviewLineTableViewCell {

    private static func createBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 9
        view.clipsToBounds = true
        return view
    }

    private static func createTitleLabel() -> UILabel {
        let titleLabel = UILabel()
        titleLabel.numberOfLines = 1
        titleLabel.textAlignment = .left
        titleLabel.text = ""
        titleLabel.font = AppFont.with(type: .semibold, size: 13)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleLabel
    }

    private static func createCollectionView() -> UICollectionView {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal

        let topCollectionView = UICollectionView.init(frame: .zero, collectionViewLayout: layout)
        topCollectionView.translatesAutoresizingMaskIntoConstraints = false
        topCollectionView.showsVerticalScrollIndicator = false
        topCollectionView.showsHorizontalScrollIndicator = false
        topCollectionView.alwaysBounceHorizontal = true
        topCollectionView.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        return topCollectionView
    }

    private func setupSubviews() {

        // Add subviews to self.view or each other
        self.contentView.addSubview(self.baseView)
        self.baseView.addSubview(self.collectionView)
        self.baseView.addSubview(self.titleLabel)

        // Initialize constraints
        self.initConstraints()
    }

    private func initConstraints() {
        NSLayoutConstraint.activate([
            self.baseView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            self.baseView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            self.baseView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            self.baseView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),

            self.titleLabel.heightAnchor.constraint(equalToConstant: 25),
            self.titleLabel.topAnchor.constraint(equalTo: self.baseView.topAnchor),
            self.titleLabel.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor, constant: 24),
            self.titleLabel.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor, constant: -18),

            self.collectionView.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor, constant: 0),
            self.collectionView.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor, constant: 0),
            self.collectionView.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor),
            self.collectionView.bottomAnchor.constraint(equalTo: self.baseView.bottomAnchor, constant: -8),
     ])
    }
}
