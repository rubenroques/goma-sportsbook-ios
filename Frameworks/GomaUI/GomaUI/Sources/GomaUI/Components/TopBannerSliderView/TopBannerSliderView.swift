import UIKit
import Combine
import SwiftUI

final public class TopBannerSliderView: UIView {
    // MARK: - Private Properties
    private let collectionView: UICollectionView
    private let pageControl = UIPageControl()
    private let pageControlContainer = UIView()
    
    private var cancellables = Set<AnyCancellable>()
    private let viewModel: TopBannerSliderViewModelProtocol
    
    private var bannerViews: [TopBannerViewProtocol] = []
    private var autoScrollTimer: Timer?
    private var currentDisplayState: TopBannerSliderDisplayState?
    
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
    
    deinit {
        stopAutoScroll()
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
        collectionView.register(BannerCollectionViewCell.self, forCellWithReuseIdentifier: "BannerCell")
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
        viewModel.displayStatePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] displayState in
                self?.render(state: displayState)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Rendering
    private func render(state: TopBannerSliderDisplayState) {
        currentDisplayState = state
        let sliderData = state.sliderData
        
        // Update visibility
        isHidden = !state.isVisible
        isUserInteractionEnabled = state.isUserInteractionEnabled
        
        // Create banner views from factories
        bannerViews = sliderData.bannerViewFactories.compactMap { factory in
            let bannerView = factory.viewFactory()
            return bannerView.isVisible ? bannerView : nil
        }
        
        // Update page control
        pageControl.numberOfPages = bannerViews.count
        pageControl.currentPage = min(sliderData.currentPageIndex, bannerViews.count - 1)
        pageControl.isHidden = !sliderData.showPageIndicators || bannerViews.count <= 1
        
        // Reload collection view
        collectionView.reloadData()
        
        // Scroll to current page if needed
        if !bannerViews.isEmpty {
            let targetPage = min(sliderData.currentPageIndex, bannerViews.count - 1)
            let indexPath = IndexPath(item: targetPage, section: 0)
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
        }
        
        // Handle auto-scroll
        if sliderData.isAutoScrollEnabled && bannerViews.count > 1 {
            self.startAutoScroll()
        } else {
            self.stopAutoScroll()
        }
    }
    
    // MARK: - Auto Scroll    
    private func scrollToNextPage() {
        guard !bannerViews.isEmpty else { return }
        
        let currentPage = pageControl.currentPage
        let nextPage = (currentPage + 1) % bannerViews.count
        
        let indexPath = IndexPath(item: nextPage, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
    // MARK: - Actions
    @objc private func pageControlValueChanged() {
        let targetPage = pageControl.currentPage
        guard targetPage < bannerViews.count else { return }
        
        let indexPath = IndexPath(item: targetPage, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        
        viewModel.didScrollToPage(targetPage)
        onPageChanged(targetPage)
    }
    
    // MARK: - Public Methods
    public func scrollToPage(_ pageIndex: Int, animated: Bool = true) {
        guard pageIndex >= 0 && pageIndex < bannerViews.count else { return }
        
        let indexPath = IndexPath(item: pageIndex, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: animated)
    }
    
    public func startAutoScroll() {
        viewModel.startAutoScroll()
    }
    
    public func stopAutoScroll() {
        viewModel.stopAutoScroll()
    }
}

// MARK: - UICollectionViewDataSource
extension TopBannerSliderView: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return bannerViews.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BannerCell", for: indexPath) as! BannerCollectionViewCell
        
        let bannerView = bannerViews[indexPath.item]
        cell.configure(with: bannerView)
        
        return cell
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
        
        if currentPage != pageControl.currentPage && currentPage >= 0 && currentPage < bannerViews.count {
            pageControl.currentPage = currentPage
            
            // Notify visibility changes
            for (index, bannerView) in bannerViews.enumerated() {
                if index == currentPage {
                    bannerView.bannerDidBecomeVisible()
                } else {
                    bannerView.bannerDidBecomeHidden()
                }
            }
            
            viewModel.didScrollToPage(currentPage)
            onPageChanged(currentPage)
        }
    }
}

// MARK: - Banner Collection View Cell
private class BannerCollectionViewCell: UICollectionViewCell {
    private var bannerView: TopBannerViewProtocol?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        bannerView?.removeFromSuperview()
        bannerView = nil
    }
    
    func configure(with bannerView: TopBannerViewProtocol) {
        // Remove previous banner view
        self.bannerView?.removeFromSuperview()
        
        // Add new banner view
        self.bannerView = bannerView
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(bannerView)
        
        NSLayoutConstraint.activate([
            bannerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            bannerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            bannerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            bannerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
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

@available(iOS 17.0, *)
#Preview("Auto Scroll Banner") {
    PreviewUIView {
        TopBannerSliderView(viewModel: MockTopBannerSliderViewModel.autoScrollMock)
    }
    .frame(height: 200)
}

@available(iOS 17.0, *)
#Preview("Casino Game Banner") {
    PreviewUIView {
        TopBannerSliderView(viewModel: MockTopBannerSliderViewModel.casinoGameMock)
    }
    .frame(height: 200)
}

#endif 
