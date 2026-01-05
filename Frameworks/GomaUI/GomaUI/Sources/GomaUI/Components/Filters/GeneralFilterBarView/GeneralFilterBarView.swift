import Foundation
import UIKit
import Combine

final public class GeneralFilterBarView: UIView {

    // MARK: - Private Properties

    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        return collectionView
    }()
    
    private let mainFilterContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    private let mainFilterView: MainFilterPillView
    
    private var cancellables = Set<AnyCancellable>()
    private let viewModel: GeneralFilterBarViewModelProtocol

    // MARK: - Public Callbacks

    public var onItemSelected: ((FilterOptionType) -> Void)?
    public var onMainFilterTapped: (() -> Void)?

    // MARK: - Data

    private var items: [FilterOptionItem] = []

    // MARK: - Initialization

    public init(viewModel: GeneralFilterBarViewModelProtocol) {
        self.viewModel = viewModel
        
        let generalFilterItems = viewModel.generalFilterItemsPublisher.value

        let pillViewModel = MockMainFilterPillViewModel(
            mainFilter: MainFilterItem(
                type: .mainFilter,
                title: generalFilterItems.mainFilterItem.title,
                icon: generalFilterItems.mainFilterItem.icon,
                actionIcon: generalFilterItems.mainFilterItem.actionIcon
            )
        )
        
        self.mainFilterView = MainFilterPillView(viewModel: pillViewModel)
        self.mainFilterView.translatesAutoresizingMaskIntoConstraints = false

        super.init(frame: .zero)
        setupSubviews()
        setupBindings()
        setupCollectionView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupSubviews() {
        backgroundColor = StyleProvider.Color.backgroundPrimary

        mainFilterContainer.addSubview(mainFilterView)

        addSubview(collectionView)
        addSubview(mainFilterContainer)

        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            collectionView.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),
            collectionView.trailingAnchor.constraint(equalTo: mainFilterContainer.leadingAnchor, constant: -8),

            mainFilterContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            mainFilterContainer.topAnchor.constraint(equalTo: topAnchor),
            mainFilterContainer.bottomAnchor.constraint(equalTo: bottomAnchor),

            mainFilterView.leadingAnchor.constraint(equalTo: mainFilterContainer.leadingAnchor, constant: 10),
            mainFilterView.trailingAnchor.constraint(equalTo: mainFilterContainer.trailingAnchor, constant: -10),
            mainFilterView.centerYAnchor.constraint(equalTo: mainFilterContainer.centerYAnchor)
        ])
    }

    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(SportSelectorCell.self, forCellWithReuseIdentifier: "SportSelectorCell")
        collectionView.register(FilterOptionCell.self, forCellWithReuseIdentifier: "FilterOptionCell")
    }

    private func setupBindings() {
        viewModel.generalFilterItemsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.configure(state: state)
            }
            .store(in: &cancellables)

        mainFilterView.onFilterTapped = { [weak self] _ in
            self?.onMainFilterTapped?()
        }
    }

    // MARK: - Configurations
    private func configure(state: GeneralFilterBarItems) {
        self.items = state.items
        collectionView.reloadData()
    }
    
    // MARK: Functions
    public func updateFilterItems(filterOptionItems: [FilterOptionItem]) {
        viewModel.updateFilterOptionItems(filterOptionItems: filterOptionItems)
    }
}

// MARK: - UICollectionViewDataSource

extension GeneralFilterBarView: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = items[indexPath.item]
        switch item.type {
        case .sport:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SportSelectorCell", for: indexPath) as! SportSelectorCell
            let viewModel = SportSelectorCellViewModel(filterOptionItem: item)
            cell.configure(with: viewModel)
            return cell
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterOptionCell", for: indexPath) as! FilterOptionCell
            let viewModel = FilterOptionCellViewModel(filterOptionItem: item)
            cell.configure(with: viewModel)
            return cell
        }
    }
}

// MARK: - UICollectionViewDelegate

extension GeneralFilterBarView: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = items[indexPath.item]
        // TODO: Action for sport selector
    }
}

#if DEBUG
import SwiftUI

@available(iOS 17.0, *)
#Preview("General Filter Bar") {
    PreviewUIView {
        GeneralFilterBarView(viewModel: MockGeneralFilterBarViewModel.defaultMock)
    }
    .frame(height: 56)
}
#endif
