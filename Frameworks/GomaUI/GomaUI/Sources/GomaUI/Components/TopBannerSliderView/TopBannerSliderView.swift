import UIKit
import Combine
import SwiftUI

final public class TopBannerSliderView: UIView {
    // MARK: - Constants
    public static let bannerHeight: CGFloat = 200

    // MARK: - Private Properties
    private let collectionView: UICollectionView
    private let pageControl = UIPageControl()
    private let pageControlContainer = UIView()

    private var cancellables = Set<AnyCancellable>()
    private var viewModel: TopBannerSliderViewModelProtocol

    private var banners: [BannerType] = []

    // MARK: - Public Properties
    public var onBannerTapped: ((Int) -> Void) = { _ in }
    public var onPageChanged: ((Int) -> Void) = { _ in }
    
    // MARK: - Initialization
    public init(viewModel: TopBannerSliderViewModelProtocol) {
        self.viewModel = viewModel
        
        // Setup collection view layout
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        super.init(frame: .zero)
        setupSubviews()
        setupBindings()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupSubviews() {
        backgroundColor = StyleProvider.Color.backgroundColor
        
        // Setup collection view
        collectionView.backgroundColor = UIColor.clear
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        // Register both cell types
        collectionView.register(SingleButtonBannerViewCell.self, forCellWithReuseIdentifier: "SingleButtonBannerCell")
        collectionView.register(MatchBannerViewCell.self, forCellWithReuseIdentifier: "MatchBannerCell")
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(collectionView)
        
        // Setup page control container
        pageControlContainer.backgroundColor = UIColor.clear
        pageControlContainer.translatesAutoresizingMaskIntoConstraints = false
        addSubview(pageControlContainer)
        
        // Setup page control
        pageControl.currentPageIndicatorTintColor = StyleProvider.Color.primaryColor
        pageControl.pageIndicatorTintColor = StyleProvider.Color.primaryColor.withAlphaComponent(0.3)
        pageControl.hidesForSinglePage = true
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.addTarget(self, action: #selector(pageControlValueChanged), for: .valueChanged)
        pageControlContainer.addSubview(pageControl)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Collection view - full size
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // Page control container - top right
            pageControlContainer.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            pageControlContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            pageControlContainer.widthAnchor.constraint(greaterThanOrEqualToConstant: 60),
            pageControlContainer.heightAnchor.constraint(equalToConstant: 30),
            
            // Page control - centered in container
            pageControl.centerXAnchor.constraint(equalTo: pageControlContainer.centerXAnchor),
            pageControl.centerYAnchor.constraint(equalTo: pageControlContainer.centerYAnchor)
        ])
    }
    
    private func setupBindings() {
        // Render initial state immediately (synchronous)
        render(state: viewModel.currentDisplayState)

        // Subscribe to future updates
        viewModel.displayStatePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] displayState in
                self?.render(state: displayState)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Rendering
    private func render(state: TopBannerSliderDisplayState) {
        let sliderData = state.sliderData

        // Update visibility
        isHidden = !state.isVisible
        isUserInteractionEnabled = state.isUserInteractionEnabled

        // Update banners array
        banners = sliderData.banners

        // Update page control
        pageControl.numberOfPages = banners.count
        pageControl.currentPage = min(sliderData.currentPageIndex, banners.count - 1)
        pageControl.isHidden = !sliderData.showPageIndicators || banners.count <= 1

        // Reload collection view
        collectionView.reloadData()

        // Scroll to current page if needed
        if !banners.isEmpty {
            let targetPage = min(sliderData.currentPageIndex, banners.count - 1)
            let indexPath = IndexPath(item: targetPage, section: 0)
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
        }
    }
    
    
    // MARK: - Actions
    @objc private func pageControlValueChanged() {
        let targetPage = pageControl.currentPage
        guard targetPage < banners.count else { return }

        let indexPath = IndexPath(item: targetPage, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)

        viewModel.didScrollToPage(targetPage)
        onPageChanged(targetPage)
    }

    // MARK: - Public Methods
    public func configure(with viewModel: TopBannerSliderViewModelProtocol) {
        // Clear existing subscriptions
        cancellables.removeAll()

        // Update the view model reference
        self.viewModel = viewModel

        // Setup new bindings with immediate rendering
        setupBindings()
    }

    public func scrollToPage(_ pageIndex: Int, animated: Bool = true) {
        guard pageIndex >= 0 && pageIndex < banners.count else { return }

        let indexPath = IndexPath(item: pageIndex, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: animated)
    }
}

// MARK: - UICollectionViewDataSource
extension TopBannerSliderView: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return banners.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let banner = banners[indexPath.item]

        switch banner {
        case .singleButton(let viewModel):
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SingleButtonBannerCell", for: indexPath) as! SingleButtonBannerViewCell
            cell.configure(with: viewModel)
            return cell

        case .matchBanner(let viewModel):
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MatchBannerCell", for: indexPath) as! MatchBannerViewCell
            cell.configure(with: viewModel)
            return cell
        }
    }
}

// MARK: - UICollectionViewDelegate
extension TopBannerSliderView: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.bannerTapped(at: indexPath.item)
        onBannerTapped(indexPath.item)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension TopBannerSliderView: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
}

// MARK: - UIScrollViewDelegate
extension TopBannerSliderView: UIScrollViewDelegate {
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updateCurrentPage()
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        updateCurrentPage()
    }
    
    private func updateCurrentPage() {
        let pageWidth = collectionView.frame.width
        guard pageWidth > 0 else { return }

        let currentPage = Int((collectionView.contentOffset.x + pageWidth / 2) / pageWidth)

        if currentPage != pageControl.currentPage && currentPage >= 0 && currentPage < banners.count {
            pageControl.currentPage = currentPage

            viewModel.didScrollToPage(currentPage)
            onPageChanged(currentPage)
        }
    }
}


// MARK: - Preview Provider
#if DEBUG

@available(iOS 17.0, *)
#Preview("Banner Slider") {
    PreviewUIView {
        TopBannerSliderView(viewModel: MockTopBannerSliderViewModel.defaultMock)
    }
    .frame(height: 200)
}

@available(iOS 17.0, *)
#Preview("Single Banner") {
    PreviewUIView {
        TopBannerSliderView(viewModel: MockTopBannerSliderViewModel.singleBannerMock)
    }
    .frame(height: 200)
}

#endif 
