//
//  ChipsTypeView.swift
//  Sportsbook
//
//  Created by Ruben Roques on 22/01/2025.
//

import UIKit
import Combine

class ChipsTypeView: UIView {

    static let height: CGFloat = 70.0

    lazy var collectionView: UICollectionView = {
        // Market Types CollectionView
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)

        var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.collectionViewLayout = layout
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceHorizontal = true
        collectionView.register(ChipCollectionViewCell.self,
                                                forCellWithReuseIdentifier: ChipCollectionViewCell.identifier)
        collectionView.register(ListBackgroundCollectionViewCell.self,
                                       forCellWithReuseIdentifier: ListBackgroundCollectionViewCell.identifier)

        collectionView.register(CompetitionListIconCollectionViewCell.self,
                                       forCellWithReuseIdentifier: CompetitionListIconCollectionViewCell.identifier)
        return collectionView
    }()

    var contentInset: UIEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16) {
        didSet {
            if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                layout.sectionInset = contentInset
            }
        }
    }

    // MARK: - Properties
    private let viewModel: ChipsTypeViewModel
    private var cancellables = Set<AnyCancellable>()

    init(viewModel: ChipsTypeViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)

        self.commonInit()
        self.setupBindings()
    }

    @available(*, unavailable)
    override init(frame: CGRect) {
        fatalError("init(frame:) has not been unavailable")
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func commonInit() {
        self.translatesAutoresizingMaskIntoConstraints = false

        self.addSubview(self.collectionView)

        self.backgroundColor = .darkGray

        self.collectionView.backgroundView?.backgroundColor = .clear
        self.collectionView.backgroundColor = .clear
        self.collectionView.delegate = self
        self.collectionView.dataSource = self

        NSLayoutConstraint.activate([
            self.heightAnchor.constraint(equalToConstant: ChipsTypeView.height),
            self.collectionView.topAnchor.constraint(equalTo: self.topAnchor),
            self.collectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            self.collectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.collectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
        ])

    }

    private func setupBindings() {
        self.viewModel.$tabs
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self = self else { return }

                // Reload the collection view
                self.collectionView.reloadData()

                // Restore selection if valid
                self.restoreSelection()
            }
            .store(in: &self.cancellables)

        self.viewModel.$selectedIndex
            .receive(on: DispatchQueue.main)
            .sink { [weak self] index in
                guard let self = self else { return }

                // Select the item if valid
                self.selectTab(at: index)
            }
            .store(in: &self.cancellables)
    }

    /// Restores the selected index after a reload if it's valid.
    private func restoreSelection() {
        guard let selectedIndex = self.viewModel.selectedIndex else { return }
        self.selectTab(at: selectedIndex)
    }

    /// Selects a tab at the given index if it's valid.
    private func selectTab(at index: Int?) {
        guard let index = index,
              index >= 0, // Ensure non-negative index
              index < self.collectionView.numberOfItems(inSection: 0) else {
            return
        }

        let indexPath = IndexPath(item: index, section: 0)
        self.collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
    }
}

// MARK: - UICollectionView DataSource & Delegate
extension ChipsTypeView: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfTabs()
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let tab = viewModel.tab(at: indexPath.item),
            let cell = collectionView.dequeueCellType(ChipCollectionViewCell.self, indexPath: indexPath)
        else {
            fatalError()
        }
        
        if case .backgroungImage = tab {
            cell.isCustomDesign = true
        }
        
        cell.setup(with: tab)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.viewModel.selectTab(at: indexPath.row)
    }
}

#if DEBUG
// MARK: - Preview, for testing purposes
// It should show the view with the various types and styles of chips

@available(iOS 17.0, *)
#Preview("ChipsTypeView") {

    // Create container view with auto layout
    let container = UIView()
    container.backgroundColor = .systemBackground
    container.translatesAutoresizingMaskIntoConstraints = false

    // Create sample data
    let sampleTabs: [ChipType] = [
        .textual(title: "Football"),
        .textual(title: "Basketball"),
        .icon(title: "Mix Match", iconName: "mix_match_icon"),
        .backgroungImage(title: "Mix Match", iconName: "mix_match_icon", imageName: "mix_match_background_pill"),
        .textual(title: "Football"),
        .textual(title: "Basketball"),
        .icon(title: "Mix Match", iconName: "mix_match_icon"),
        .backgroungImage(title: "Mix Match", iconName: "mix_match_icon", imageName: "mix_match_background_pill"),
        .textual(title: "Football"),
        .textual(title: "Basketball"),
        .icon(title: "Mix Match", iconName: "mix_match_icon"),
        .backgroungImage(title: "Mix Match", iconName: "mix_match_icon", imageName: "mix_match_background_pill"),
        .textual(title: "Football"),
        .textual(title: "Basketball"),
        .icon(title: "Mix Match", iconName: "mix_match_icon"),
        .backgroungImage(title: "Mix Match", iconName: "mix_match_icon", imageName: "mix_match_background_pill"),
    ]

    // Create ChipsTypeView with ViewModel
    let viewModel = ChipsTypeViewModel(tabs: sampleTabs, defaultSelectedIndex: 1)
    let chipsView = ChipsTypeView(viewModel: viewModel)
    container.addSubview(chipsView)

    // Setup constraints
    NSLayoutConstraint.activate([
        chipsView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
        chipsView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
        chipsView.topAnchor.constraint(equalTo: container.topAnchor, constant: 20),
        container.heightAnchor.constraint(equalToConstant: ChipsTypeView.height + 40)
    ])

    return container
}
#endif
