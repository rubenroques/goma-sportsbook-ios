//
//  BetbuilderLineTableViewCell.swift
//  Sportsbook
//
//  Created by André Lascas on 25/02/2025.
//

import UIKit
import Combine

class BetbuilderLineCellViewModel {
    
    var betBuilderOptions: [BetbuilderSelectionCellViewModel]
    
    init(betBuilderoptions: [BetbuilderSelectionCellViewModel]) {
        self.betBuilderOptions = betBuilderoptions
    }
}

class BetbuilderLineTableViewCell: UITableViewCell {

    // MARK: Private properties
    private lazy var collectionView: UICollectionView = Self.createCollectionView()
    
    private let cellHeight: CGFloat = 124

    var viewModel: BetbuilderLineCellViewModel?
    
    var cancellables = Set<AnyCancellable>()

    var presentationMode: ClientManagedHomeViewTemplateDataSource.HighlightsPresentationMode = .multiplesPerLineByType
    
    var shouldHideBetbuilderLine: ((BetbuilderLineCellViewModel) -> Void)?

    // MARK: Lifetime and cycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.setupSubviews()
        self.commonInit()
        self.setupWithTheme()
        
        self.setupPublishers()
    }

    @available(iOS, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.viewModel = nil
        
    }
    
    private func commonInit() {

        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.register(BetbuilderSelectionCollectionViewCell.self,
                                     forCellWithReuseIdentifier: BetbuilderSelectionCollectionViewCell.identifier)
    }
    
    // MARK: Layout and theme
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.collectionView.isScrollEnabled = self.presentationMode == .multiplesPerLineByType
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.setupWithTheme()
    }

    func setupWithTheme() {
        self.backgroundColor = .clear
        self.backgroundView?.backgroundColor = .clear
        self.contentView.backgroundColor = .clear

        self.collectionView.backgroundView?.backgroundColor = UIColor.App.backgroundPrimary
        self.collectionView.backgroundColor = UIColor.App.backgroundPrimary

    }
    
    // MARK: Functions
    func configure(withViewModel viewModel: BetbuilderLineCellViewModel, presentationMode: ClientManagedHomeViewTemplateDataSource.HighlightsPresentationMode) {

        self.viewModel = viewModel
        
        self.presentationMode = presentationMode
        
        self.collectionView.reloadData()
    }
    
    func setupPublishers() {
        
        Env.betslipManager.bettingTicketsPublisher
            .removeDuplicates()
            .debounce(for: .milliseconds(200), scheduler: DispatchQueue.main)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] bettingTickets in
                
                guard let self = self else { return }
                
                self.collectionView.reloadData()
                
            })
            .store(in: &cancellables)
    }
}

extension BetbuilderLineTableViewCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel?.betBuilderOptions.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let cell = collectionView.dequeueCellType(BetbuilderSelectionCollectionViewCell.self, indexPath: indexPath),
            let cellViewModel = self.viewModel?.betBuilderOptions[safe: indexPath.row]
        else {
            fatalError()
        }
        
        cell.configure(viewModel: cellViewModel)
        
        cell.shouldHideBetbuilderSelection = { [weak self] in
                guard let self = self, let viewModel = self.viewModel else { return }
                
                if let index = viewModel.betBuilderOptions.firstIndex(where: { $0 === cellViewModel }) {
                    viewModel.betBuilderOptions.remove(at: index)
                    
                    self.collectionView.reloadData()
                    
                    if viewModel.betBuilderOptions.isEmpty {
//                        NotificationCenter.default.post(
//                            name: NSNotification.Name("HideBetbuilderLineCell"),
//                            object: nil,
//                            userInfo: ["cellViewModel": viewModel]
//                        )
                        self.shouldHideBetbuilderLine?(viewModel)
                    }
                    
                }
            }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenWidth = UIScreen.main.bounds.width
        var cellWidth = screenWidth * 0.85

        switch self.presentationMode {
        case .onePerLine:
            cellWidth = screenWidth - 32  // Full width minus margins
        case .multiplesPerLineByType:
            cellWidth = screenWidth * 0.85

        }
        
        return CGSize(width: cellWidth, height: 184)
    }

}

extension BetbuilderLineTableViewCell {
    
    private static func createCollectionView() -> UICollectionView {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        layout.minimumLineSpacing = 14

        var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }
    
    private func setupSubviews() {
        self.contentView.addSubview(self.collectionView)
        
        self.initConstraints()
    }
    
    private func initConstraints() {
        
        NSLayoutConstraint.activate([
            self.collectionView.heightAnchor.constraint(equalToConstant: self.cellHeight),
            self.collectionView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            self.collectionView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            self.collectionView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            self.collectionView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
            self.collectionView.heightAnchor.constraint(equalToConstant: 200)
        ])
    }
}
