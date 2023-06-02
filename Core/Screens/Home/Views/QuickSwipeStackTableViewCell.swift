//
//  QuickSwipeStackTableViewCell.swift
//  Sportsbook
//
//  Created by Ruben Roques on 04/05/2022.
//

import UIKit

class QuickSwipeStackCellViewModel {

    var title: String?
    var matches: [Match]

    private var cellViewModelsCache: [String: MatchWidgetCellViewModel] = [:]

    init(title: String?, matches: [Match]) {
        self.matches = matches
        self.title = title
    }

    func numberOfItems() -> Int {
        return matches.count
    }

    func matchViewModel(forIndex index: Int) -> MatchWidgetCellViewModel? {
        guard
            let match = self.matches[safe: index]
        else {
            return nil
        }

        if let viewModel = cellViewModelsCache[match.id] {
            return viewModel
        }
        else {
            let viewModel = MatchWidgetCellViewModel(match: match)
            cellViewModelsCache[match.id] = viewModel
            return viewModel
        }
    }

    var titleSection: String {
        return (self.title ?? "").uppercased()
    }
}

class QuickSwipeStackTableViewCell: UITableViewCell {

    var didTapMatchAction: ((Match) -> Void) = { _ in }

    private let cellHeight: CGFloat = 240.0

    private lazy var baseView: UIView = Self.createBaseView()
    private lazy var collectionView: UICollectionView = Self.createCollectionView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()

    private var viewModel: QuickSwipeStackCellViewModel?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.setupSubviews()
        self.setupWithTheme()

        self.collectionView.delegate = self
        self.collectionView.dataSource = self

        self.collectionView.register(MatchWidgetCollectionViewCell.nib, forCellWithReuseIdentifier: MatchWidgetCollectionViewCell.identifier)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()

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
        self.contentView.backgroundColor = .clear

        self.baseView.backgroundColor = .clear

        self.collectionView.backgroundView?.backgroundColor = .clear
        self.collectionView.backgroundColor = .clear

        self.titleLabel.textColor = UIColor.App.textPrimary
    }

    func configure(withViewModel viewModel: QuickSwipeStackCellViewModel) {
        self.viewModel = viewModel
        self.titleLabel.text = viewModel.titleSection
        self.reloadData()
    }

    func reloadData() {
        self.collectionView.reloadData()
    }

}

extension QuickSwipeStackTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel?.numberOfItems() ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard
            let cell = collectionView.dequeueCellType(MatchWidgetCollectionViewCell.self, indexPath: indexPath),
            let viewModel = self.viewModel?.matchViewModel(forIndex: indexPath.row)
        else {
            fatalError()
        }

        cell.configure(withViewModel: viewModel)
        cell.tappedMatchWidgetAction = { [weak self] in
            if let match = viewModel.match {
                self?.didTapMatchAction(match)
            }
        }
        cell.shouldShowCountryFlag(true)
        return cell

    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let topMargin: CGFloat = 10.0
        let leftMargin: CGFloat = 18.0
        return CGSize(width: collectionView.frame.size.width - (leftMargin * 2.0),
                      height: collectionView.frame.size.height - (topMargin * 2.0))
    }

}

extension QuickSwipeStackTableViewCell {

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
        let layout = QuickSwipeStackCollectionViewLayout()
        let topCollectionView = UICollectionView.init(frame: .zero, collectionViewLayout: layout)
        topCollectionView.translatesAutoresizingMaskIntoConstraints = false
        topCollectionView.showsVerticalScrollIndicator = false
        topCollectionView.showsHorizontalScrollIndicator = false
        topCollectionView.isPagingEnabled = true
        topCollectionView.clipsToBounds = false
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
            self.baseView.heightAnchor.constraint(equalToConstant: self.cellHeight),

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
            self.collectionView.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 12),
            self.collectionView.bottomAnchor.constraint(equalTo: self.baseView.bottomAnchor, constant: -8),
     ])
    }
}
