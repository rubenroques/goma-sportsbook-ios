import Foundation
import UIKit
import Combine
import SwiftUI

final public class PromotionalBonusCardsScrollView: UIView {
    // MARK: - Private Properties
    private let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.showsHorizontalScrollIndicator = false
        scroll.showsVerticalScrollIndicator = false
        scroll.isPagingEnabled = false
        scroll.decelerationRate = .fast
        return scroll
    }()
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 16
        stack.alignment = .fill
        stack.distribution = .fill
        return stack
    }()
    
    private var cancellables = Set<AnyCancellable>()
    private let viewModel: PromotionalBonusCardsScrollViewModelProtocol
    private var cardViews: [String: PromotionalBonusCardView] = [:]
    
    // MARK: - Public Properties
    public var onCardClaimBonus: ((PromotionalBonusCardData) -> Void) = { _ in }
    public var onCardTermsTapped: ((PromotionalBonusCardData) -> Void) = { _ in }
    
    // MARK: - Initialization
    public init(viewModel: PromotionalBonusCardsScrollViewModelProtocol) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupSubviews()
        setupBindings()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupSubviews() {
        backgroundColor = .clear
        
        addSubview(scrollView)
        scrollView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        ])
    }
    
    private func setupBindings() {
        viewModel.cardsDataPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] cardsData in
                self?.configure(cardsData: cardsData)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Configuration
    private func configure(cardsData: PromotionalBonusCardsData) {
        // Clear existing card views
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        cardViews.removeAll()
        
        // Create card views
        for cardData in cardsData.cards {
            let cardViewModel = MockPromotionalBonusCardViewModel(cardData: cardData)
            let cardView = PromotionalBonusCardView(viewModel: cardViewModel)
            
            // Set up card actions
            cardView.onClaimBonus = { [weak self] in
                self?.viewModel.cardClaimBonusTapped(cardId: cardData.id)
                self?.onCardClaimBonus(cardData)
            }
            
            cardView.onTermsTapped = { [weak self] in
                self?.viewModel.cardTermsTapped(cardId: cardData.id)
                self?.onCardTermsTapped(cardData)
            }
            
            cardView.translatesAutoresizingMaskIntoConstraints = false
            
            // Calculate card width as percentage of screen width
            let screenWidth = UIScreen.main.bounds.width
            let cardWidth = screenWidth * 0.85
            
            NSLayoutConstraint.activate([
                cardView.widthAnchor.constraint(equalToConstant: cardWidth)
            ])
            
            stackView.addArrangedSubview(cardView)
            cardViews[cardData.id] = cardView
        }
    }
}

// MARK: - Preview Provider
#if DEBUG

@available(iOS 17.0, *)
#Preview("PromotionalBonusCardsScrollView") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = StyleProvider.Color.backgroundPrimary

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 32
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false

        // Component name label
        let titleLabel = UILabel()
        titleLabel.text = "PromotionalBonusCardsScrollView"
        titleLabel.font = StyleProvider.fontWith(type: .bold, size: 18)
        titleLabel.textColor = StyleProvider.Color.textPrimary
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        // Default mock - 4 cards
        let defaultCardsView = PromotionalBonusCardsScrollView(viewModel: MockPromotionalBonusCardsScrollViewModel.defaultMock)
        defaultCardsView.translatesAutoresizingMaskIntoConstraints = false

        // Short list mock - 2 cards
        let shortListCardsView = PromotionalBonusCardsScrollView(viewModel: MockPromotionalBonusCardsScrollViewModel.shortListMock)
        shortListCardsView.translatesAutoresizingMaskIntoConstraints = false

        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(defaultCardsView)
        stackView.addArrangedSubview(shortListCardsView)

        vc.view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor),

            // Fixed heights for horizontal scroll views
            defaultCardsView.heightAnchor.constraint(equalToConstant: 200),
            shortListCardsView.heightAnchor.constraint(equalToConstant: 200)
        ])

        return vc
    }
}

#endif
