import UIKit
import Combine
import SwiftUI

final public class SuggestedBetsExpandedView: UIView {

    // MARK: - UI Components
    private lazy var containerView = Self.createContainerView()
    private lazy var headerContainerView = Self.createHeaderContainerView()
    private lazy var leftIconImageView = Self.createLeftIconImageView()
    private lazy var titleLabel = Self.createTitleLabel()
    private lazy var chevronImageView = Self.createChevronImageView()
    private lazy var contentContainerView = Self.createContentContainerView()
    private lazy var collectionView: UICollectionView = Self.createCollectionView()
    private lazy var pageControl = Self.createPageControl()

    // MARK: - State
    private var cancellables = Set<AnyCancellable>()
    private var viewModel: SuggestedBetsExpandedViewModelProtocol
    private var itemViewModels: [TallOddsMatchCardViewModelProtocol] = []
    private var headerBottomConstraint: NSLayoutConstraint?
    private var hasBeenExpandedBefore = false
   

    // MARK: - Init
    public init(viewModel: SuggestedBetsExpandedViewModelProtocol) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupSubviews()
        setupBindings()
    }

    required init?(coder: NSCoder) {
        return nil
    }

    // MARK: - Public
    public func configure(with newViewModel: SuggestedBetsExpandedViewModelProtocol) {
        cancellables.removeAll()
        self.viewModel = newViewModel
        setupBindings()
    }
}

// MARK: - Setup
extension SuggestedBetsExpandedView {
    private static func createContainerView() -> GradientView {

        let gradient = GradientView()
        gradient.translatesAutoresizingMaskIntoConstraints = false
        gradient.colors = [
            (StyleProvider.Color.backgroundGradient1, 0.3345),
            (StyleProvider.Color.backgroundGradient2, 1.0)
        ]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
        return gradient
    }

    private static func createHeaderContainerView() -> GradientView {

        let gradient = GradientView()
        gradient.translatesAutoresizingMaskIntoConstraints = false
        gradient.colors = [
            (StyleProvider.Color.allWhite, 0.2749),
            (StyleProvider.Color.backgroundGradient2, 0.959)
        ]
        gradient.startPoint = CGPoint(x: 0.1, y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
        return gradient
    }

    private static func createLeftIconImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        
        if let customImage = UIImage(named: "popular_icon") {
            imageView.image = customImage.withRenderingMode(.alwaysTemplate)
        }
        else {
            imageView.image = UIImage(systemName: "flame.fill")?.withRenderingMode(.alwaysTemplate)
        }
        imageView.tintColor = StyleProvider.Color.highlightPrimary
        return imageView
    }

    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .bold, size: 14)
        label.textColor = StyleProvider.Color.highlightPrimary
        label.numberOfLines = 0
        return label
    }

    private static func createChevronImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false

        let symbolConfig = UIImage.SymbolConfiguration(weight: .bold)

        if let customImage = UIImage(named: "chevron_down_icon") {
            imageView.image = customImage.withRenderingMode(.alwaysTemplate)
        }
        else {
            
        }
        
        imageView.image = UIImage(systemName: "chevron.down", withConfiguration: symbolConfig)?.withRenderingMode(.alwaysTemplate)
        
        imageView.tintColor = StyleProvider.Color.highlightPrimary
        imageView.contentMode = .scaleAspectFit
        return imageView
    }

    private static func createContentContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }

    private static func createCollectionView() -> UICollectionView {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = UIColor.clear
        collectionView.isPagingEnabled = true
        collectionView.register(SuggestedBetsMatchCardCell.self, forCellWithReuseIdentifier: SuggestedBetsMatchCardCell.reuseId)
        return collectionView
    }

    private static func createPageControl() -> UIPageControl {
        let pageControl = UIPageControl()
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.currentPageIndicatorTintColor = StyleProvider.Color.navBannerActive
        pageControl.pageIndicatorTintColor = StyleProvider.Color.navBanner
        pageControl.hidesForSinglePage = true
        return pageControl
    }

    private func setupSubviews() {
        addSubview(containerView)
        containerView.addSubview(headerContainerView)
        headerContainerView.addSubview(leftIconImageView)
        headerContainerView.addSubview(titleLabel)
        headerContainerView.addSubview(chevronImageView)
        containerView.addSubview(contentContainerView)
        contentContainerView.addSubview(collectionView)
        contentContainerView.addSubview(pageControl)

        collectionView.dataSource = self
        collectionView.delegate = self

        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),

            headerContainerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            headerContainerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            headerContainerView.topAnchor.constraint(equalTo: containerView.topAnchor),
            headerContainerView.heightAnchor.constraint(equalToConstant: 34),

            leftIconImageView.leadingAnchor.constraint(equalTo: headerContainerView.leadingAnchor, constant: 8),
            leftIconImageView.centerYAnchor.constraint(equalTo: headerContainerView.centerYAnchor),
            leftIconImageView.widthAnchor.constraint(equalToConstant: 16),
            leftIconImageView.heightAnchor.constraint(equalTo: leftIconImageView.widthAnchor),

            chevronImageView.centerYAnchor.constraint(equalTo: headerContainerView.centerYAnchor),
            chevronImageView.trailingAnchor.constraint(equalTo: headerContainerView.trailingAnchor, constant: -8),
            chevronImageView.widthAnchor.constraint(equalToConstant: 18),
            chevronImageView.heightAnchor.constraint(equalTo: chevronImageView.widthAnchor),

            titleLabel.leadingAnchor.constraint(equalTo: leftIconImageView.trailingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: chevronImageView.leadingAnchor, constant: -8),
            titleLabel.topAnchor.constraint(equalTo: headerContainerView.topAnchor, constant: 4),
            titleLabel.bottomAnchor.constraint(equalTo: headerContainerView.bottomAnchor, constant: -4),

            contentContainerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            contentContainerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            contentContainerView.topAnchor.constraint(equalTo: headerContainerView.bottomAnchor),
            contentContainerView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),

            collectionView.leadingAnchor.constraint(equalTo: contentContainerView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: contentContainerView.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: contentContainerView.topAnchor, constant: 12),
            collectionView.heightAnchor.constraint(equalToConstant: 152),

            pageControl.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 8),
            pageControl.centerXAnchor.constraint(equalTo: contentContainerView.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: contentContainerView.bottomAnchor)
        ])

        let tap = UITapGestureRecognizer(target: self, action: #selector(toggleExpandedTapped))
        headerContainerView.addGestureRecognizer(tap)
        headerContainerView.isUserInteractionEnabled = true
        pageControl.addTarget(self, action: #selector(pageControlChanged), for: .valueChanged)
        let pageControlTap = UITapGestureRecognizer(target: self, action: #selector(pageControlTapped(_:)))
        pageControl.addGestureRecognizer(pageControlTap)

        // Constraint used when collapsed: header sticks to bottom
        headerBottomConstraint = headerContainerView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
    }

    private func setupBindings() {
        viewModel.displayStatePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.render(state: state)
            }
            .store(in: &cancellables)

        viewModel.matchCardViewModelsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] models in
                self?.itemViewModels = models
                self?.pageControl.numberOfPages = models.count
            }
            .store(in: &cancellables)
        
        viewModel.selectedOutcomeIdsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.collectionView.reloadData()
            }
            .store(in: &cancellables)
        
    }

    private func render(state: SuggestedBetsSectionState) {
        isHidden = !state.isVisible
        titleLabel.text = state.title
        
        self.setCollapsedIconState(isExpanded: state.isExpanded)
        pageControl.isHidden = !state.isExpanded || state.totalPages <= 1

        if state.isExpanded {
            headerBottomConstraint?.isActive = false
            
            if !hasBeenExpandedBefore {
                hasBeenExpandedBefore = true
                DispatchQueue.main.async {
                    self.layoutIfNeeded()
                    self.collectionView.layoutIfNeeded()
                    self.collectionView.reloadData()
                }
            }
        } else {
            headerBottomConstraint?.isActive = true
        }
        
        pageControl.numberOfPages = max(state.totalPages, itemViewModels.count)
        pageControl.currentPage = min(state.currentPageIndex, max(pageControl.numberOfPages - 1, 0))
    }

    
    
    private func setCollapsedIconState(isExpanded: Bool) {
        let symbolConfig = UIImage.SymbolConfiguration(weight: .bold)

        if isExpanded {
            if let customImage = UIImage(named: "chevron_up_icon") {
                chevronImageView.image = customImage.withRenderingMode(.alwaysTemplate)
            }
            else {
                chevronImageView.image = UIImage(systemName: "chevron.up", withConfiguration: symbolConfig)?.withRenderingMode(.alwaysTemplate)
            }
        }
        else {
            if let customImage = UIImage(named: "chevron_down_icon") {
                chevronImageView.image = customImage.withRenderingMode(.alwaysTemplate)
            }
            else {
                chevronImageView.image = UIImage(systemName: "chevron.down", withConfiguration: symbolConfig)?.withRenderingMode(.alwaysTemplate)
            }
        }
    }

    @objc private func toggleExpandedTapped() {
        viewModel.toggleExpanded()
    }

    @objc private func pageControlChanged() {
        let targetPage = pageControl.currentPage
        guard targetPage < itemViewModels.count, targetPage >= 0 else { return }
        // Use direct content offset to avoid layout misalignment when jumping across pages
        collectionView.layoutIfNeeded()
        let width = max(collectionView.bounds.width, 1)
        let x = CGFloat(targetPage) * width
        collectionView.setContentOffset(CGPoint(x: x, y: 0), animated: true)
        viewModel.didScrollToPage(targetPage)
    }

    @objc private func pageControlTapped(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: pageControl)
        let width = pageControl.bounds.width
        let numberOfPages = pageControl.numberOfPages
        let page = Int(location.x / (width / CGFloat(numberOfPages)))
        
        guard page != pageControl.currentPage else { return } // Only act if a different page is tapped
        
        pageControl.currentPage = page
        pageControlChanged() // Trigger the same logic as valueChanged
    }
}

// MARK: - CollectionView
extension SuggestedBetsExpandedView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemViewModels.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SuggestedBetsMatchCardCell.reuseId, for: indexPath) as! SuggestedBetsMatchCardCell
        let viewModel = itemViewModels[indexPath.item]
        cell.configure(with: viewModel, selectedOutcomeIds: self.viewModel.selectedOutcomeIds)
        
        return cell
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: collectionView.bounds.height)
    }

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = Int(round(scrollView.contentOffset.x / max(scrollView.bounds.width, 1)))
        pageControl.currentPage = page
        viewModel.didScrollToPage(page)
    }
}

// MARK: - Cell Wrapper
final class SuggestedBetsMatchCardCell: UICollectionViewCell {
    static let reuseId = "SuggestedBetsMatchCardCell"
    private var matchCardView: TallOddsMatchCardView?
    private var cancellables = Set<AnyCancellable>()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = UIColor.clear
    }

    required init?(coder: NSCoder) {
        return nil
    }

    func configure(with viewModel: TallOddsMatchCardViewModelProtocol,
                   selectedOutcomeIds: Set<String>) {
        
        cancellables.removeAll()
        
        if let existing = matchCardView {
            existing.configure(with: viewModel)
        } else {
            let view = TallOddsMatchCardView(viewModel: viewModel, customBackgroundColor: .clear)
            view.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(view)
            NSLayoutConstraint.activate([
                view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
                view.topAnchor.constraint(equalTo: contentView.topAnchor),
                view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
            ])
            matchCardView = view
        }
        
        viewModel.marketOutcomesViewModelPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] marketOutcomes in
                
                // Check each line view model for all outcomes
                for lineViewModel in marketOutcomes.lineViewModels {
                    // Check left outcome
                    if let leftOutcome = lineViewModel.marketStateSubject.value.leftOutcome {
                        let shouldBeSelected = selectedOutcomeIds.contains(leftOutcome.id)
                        if shouldBeSelected {
                            lineViewModel.setOutcomeSelected(type: .left)
                        } else {
                            lineViewModel.setOutcomeDeselected(type: .left)
                        }
                    }
                    
                    // Check middle outcome
                    if let middleOutcome = lineViewModel.marketStateSubject.value.middleOutcome {
                        let shouldBeSelected = selectedOutcomeIds.contains(middleOutcome.id)
                        if shouldBeSelected {
                            lineViewModel.setOutcomeSelected(type: .middle)
                        } else {
                            lineViewModel.setOutcomeDeselected(type: .middle)
                        }
                    }
                    
                    // Check right outcome
                    if let rightOutcome = lineViewModel.marketStateSubject.value.rightOutcome {
                        let shouldBeSelected = selectedOutcomeIds.contains(rightOutcome.id)
                        if shouldBeSelected {
                            lineViewModel.setOutcomeSelected(type: .right)
                        } else {
                            lineViewModel.setOutcomeDeselected(type: .right)
                        }
                    }
                }
            })
            .store(in: &cancellables)
    }
}

// MARK: - SwiftUI Preview
#if DEBUG
@available(iOS 17.0, *)
#Preview("Suggested Bets Expanded") {
    PreviewUIViewController {
        let viewModel = MockSuggestedBetsExpandedViewModel.demo
        let vc = UIViewController()
        vc.view.backgroundColor = StyleProvider.Color.backgroundOdds
        let component = SuggestedBetsExpandedView(viewModel: viewModel)
        component.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(component)
        NSLayoutConstraint.activate([
            component.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor),
            component.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor),
            component.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor, constant: 16)
        ])
        return vc
    }
}
#endif
