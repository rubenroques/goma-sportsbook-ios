//
//  PromotionCardViewController.swift
//  GomaUIDemo
//
//  Created by Claude on 29/08/2025.
//

import UIKit
import GomaUI

class PromotionCardViewController: UIViewController {
    
    // MARK: - Private Properties
    private lazy var scrollView: UIScrollView = Self.createScrollView()
    private lazy var contentView: UIView = Self.createContentView()
    private lazy var stackView: UIStackView = Self.createStackView()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        self.setupWithTheme()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupWithTheme()
    }
    
    // MARK: - Setup
    private func setupView() {
        self.setupSubviews()
        self.setupPromotionCards()
    }
    
    private func setupWithTheme() {
        self.view.backgroundColor = StyleProvider.Color.backgroundColor
        self.contentView.backgroundColor = .clear
    }
    
    private func setupPromotionCards() {
        // Default mock
        let defaultCard = PromotionCardView(viewModel: MockPromotionCardViewModel.defaultMock)
        defaultCard.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(defaultCard)
        
        // Casino mock
        let casinoCard = PromotionCardView(viewModel: MockPromotionCardViewModel.casinoMock)
        casinoCard.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(casinoCard)
        
        // Sportsbook mock
        let sportsbookCard = PromotionCardView(viewModel: MockPromotionCardViewModel.sportsbookMock)
        sportsbookCard.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(sportsbookCard)
        
        // No CTA mock
        let noCTACard = PromotionCardView(viewModel: MockPromotionCardViewModel.noCTAMock)
        noCTACard.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(noCTACard)
        
        // Long title mock
        let longTitleCard = PromotionCardView(viewModel: MockPromotionCardViewModel.longTitleMock)
        longTitleCard.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(longTitleCard)
        
        // No tag mock
        let noTagCard = PromotionCardView(viewModel: MockPromotionCardViewModel.noTagMock)
        noTagCard.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(noTagCard)
    }
}

// MARK: - Subviews Initialization and Setup
extension PromotionCardViewController {
    
    private static func createScrollView() -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }
    
    private static func createContentView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .fill
        return stackView
    }
    
    private func setupSubviews() {
        self.view.addSubview(self.scrollView)
        self.scrollView.addSubview(self.contentView)
        self.contentView.addSubview(self.stackView)
        
        self.initConstraints()
    }
    
    private func initConstraints() {
        NSLayoutConstraint.activate([
            // ScrollView
            self.scrollView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            self.scrollView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            self.scrollView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            self.scrollView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            
            // ContentView
            self.contentView.leadingAnchor.constraint(equalTo: self.scrollView.leadingAnchor),
            self.contentView.trailingAnchor.constraint(equalTo: self.scrollView.trailingAnchor),
            self.contentView.topAnchor.constraint(equalTo: self.scrollView.topAnchor),
            self.contentView.bottomAnchor.constraint(equalTo: self.scrollView.bottomAnchor),
            self.contentView.widthAnchor.constraint(equalTo: self.scrollView.widthAnchor),
            
            // StackView
            self.stackView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 16),
            self.stackView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -16),
            self.stackView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 20),
            self.stackView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -20)
        ])
    }
}

// MARK: - Preview Factory
extension PromotionCardViewController {
    static func makePreview() -> PromotionCardViewController {
        let vc = PromotionCardViewController()
        return vc
    }
}
