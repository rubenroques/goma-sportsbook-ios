import UIKit
import Combine
import SwiftUI

final public class SportTypeSelectorView: UIView {
    
    // MARK: - Private Properties
    private var collectionView: UICollectionView!
    private var cancellables = Set<AnyCancellable>()
    private let viewModel: SportTypeSelectorViewModelProtocol
    private var currentSports: [SportTypeData] = []
    
    // MARK: - Public Properties
    public var onSportSelected: ((SportTypeData) -> Void) = { _ in }
    
    // MARK: - Initialization
    public init(viewModel: SportTypeSelectorViewModelProtocol) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupCollectionView()
        setupBindings()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupCollectionView() {
        backgroundColor = StyleProvider.Color.backgroundTertiary
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView.register(
            SportTypeSelectorCollectionViewCell.self,
            forCellWithReuseIdentifier: SportTypeSelectorCollectionViewCell.reuseIdentifier
        )
        
        addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    private func setupBindings() {
        viewModel.displayStatePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] displayState in
                self?.render(state: displayState)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Rendering
    private func render(state: SportTypeSelectorDisplayState) {
        currentSports = state.sports
        collectionView.reloadData()
    }
}

// MARK: - UICollectionViewDataSource
extension SportTypeSelectorView: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currentSports.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: SportTypeSelectorCollectionViewCell.reuseIdentifier,
            for: indexPath
        ) as! SportTypeSelectorCollectionViewCell
        
        let sportData = currentSports[indexPath.item]
        let mockViewModel = MockSportTypeSelectorItemViewModel(sportData: sportData)
        
        cell.configure(with: mockViewModel) { [weak self] selectedSport in
            self?.onSportSelected(selectedSport)
        }
        
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension SportTypeSelectorView: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 8 * 3 // left + right + middle spacing
        let availableWidth = collectionView.bounds.width - padding
        let itemWidth = availableWidth / 2
        return CGSize(width: itemWidth,
                      height: SportTypeSelectorItemView.defaultHeight)
    }
}

// MARK: - Preview Provider
#if DEBUG

@available(iOS 17.0, *)
#Preview("Default") {
    PreviewUIView {
        SportTypeSelectorView(viewModel: MockSportTypeSelectorViewModel.defaultMock)
    }
    .frame(height: 400)
    .background(Color(UIColor.red))
}

@available(iOS 17.0, *)
#Preview("Many Sports") {
    PreviewUIView {
        SportTypeSelectorView(viewModel: MockSportTypeSelectorViewModel.manySportsMock)
    }
    .frame(height: 600)
    .background(Color(UIColor.red))
}

#endif
