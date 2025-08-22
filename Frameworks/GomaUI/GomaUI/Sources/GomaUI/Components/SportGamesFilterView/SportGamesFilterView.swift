//
//  GamesView.swift
//  GomaUI
//
//  Created by André Lascas on 23/05/2025.
//

import Foundation
import UIKit
import Combine

public class SportGamesFilterView: UIView {
    // MARK: - Properties
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Games"
        label.font = StyleProvider.fontWith(type: .bold, size: 14)
        label.textColor = StyleProvider.Color.textPrimary
        return label
    }()
    
    private let gridStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 8
        return stack
    }()
    
    private let collapseButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        if let customImage = UIImage(named: "chevron_up_icon")?.withRenderingMode(.alwaysTemplate) {
            button.setImage(customImage, for: .normal)
        }
        else if let systemImage = UIImage(systemName: "chevron.down")?.withRenderingMode(.alwaysTemplate) {
            button.setImage(systemImage, for: .normal)
        }
        button.tintColor = StyleProvider.Color.iconPrimary
        return button
    }()
    
    // Constraints
    private var gridStackViewBottomConstraint: NSLayoutConstraint = {
        NSLayoutConstraint()
    }()
    
    private var gridStackViewHeightConstraint: NSLayoutConstraint = {
        NSLayoutConstraint()
    }()
    
    private let viewModel: SportGamesFilterViewModelProtocol
    private var cancellables = Set<AnyCancellable>()

    private var sportCards: [SportCardView] = []
    public var onSportSelected: ((String) -> Void)?
    
    private var isCollapsed: Bool = false {
        didSet {
            updateCollapseState()
        }
    }
    
    // MARK: - Initialization
    public init(viewModel: SportGamesFilterViewModelProtocol) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupView()
        setupBindings()
        configureData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupView() {
        backgroundColor = StyleProvider.Color.backgroundTertiary
        layer.cornerRadius = 8
        
        addSubview(titleLabel)
        addSubview(collapseButton)
        addSubview(gridStackView)
        
        gridStackViewBottomConstraint = gridStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        gridStackViewHeightConstraint = gridStackView.heightAnchor.constraint(equalToConstant: 0)
        gridStackViewHeightConstraint.isActive = false

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: collapseButton.leadingAnchor, constant: -10),
            
            collapseButton.widthAnchor.constraint(equalToConstant: 24),
            collapseButton.heightAnchor.constraint(equalToConstant: 24),
            collapseButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            collapseButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            
            gridStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            gridStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            gridStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            gridStackViewBottomConstraint
        ])
        
        self.titleLabel.text = viewModel.title
        
        collapseButton.addTarget(self, action: #selector(toggleCollapse), for: .touchUpInside)

    }
    
    private func setupBindings() {
        viewModel.sportFilterState
            .sink { [weak self] state in
                self?.isCollapsed = state == .collapsed
            }
            .store(in: &cancellables)
        
        viewModel.selectedId
            .sink(receiveValue: { [weak self] selectedId in
                self?.updateSelection(forOptionId: selectedId)
            })
            .store(in: &cancellables)
    }
    
    private func createRowStackView() -> UIStackView {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 8
        return stack
    }
    
    // MARK: - Public Methods
    private func configureData() {
        // Clear existing views
        gridStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        sportCards.removeAll()
        
        var currentRow: UIStackView?
        
        for (index, sport) in viewModel.sportFilters.enumerated() {
            if index % 2 == 0 {
                currentRow = createRowStackView()
                gridStackView.addArrangedSubview(currentRow!)
            }
            
            let cardViewModel = MockSportCardViewModel(sportFilter: sport)
            let card = SportCardView(viewModel: cardViewModel)
            card.configure()
            card.isSelected = self.viewModel.selectedId.value == sport.id ? true : false
            
            let cardIndex = index
            card.onTap = { [weak self] selectedId in
                self?.viewModel.selectOption(withId: selectedId)
            }
            
            currentRow?.addArrangedSubview(card)
            sportCards.append(card)
        }
        
        // If we have an odd number of sports, add an empty view to maintain layout
        if viewModel.sportFilters.count % 2 != 0, let lastRow = currentRow {
            let emptyView = UIView()
            lastRow.addArrangedSubview(emptyView)
        }
    }
    
    @objc private func toggleCollapse() {
        viewModel.didTapCollapseButton()
    }
    
    private func updateSelection(forOptionId id: String) {
        sportCards.forEach { row in
            row.isSelected = row.viewModel.sportFilter.id == id
            
        }
        
        self.onSportSelected?(id)
    }
    
//    private func handleCardSelection(at index: Int) {
//        // Update selection state
//        sportCards.enumerated().forEach { (idx, card) in
//            card.isSelected = idx == index
//        }
//        viewModel.didSelectSportFilter(at: index)
//    }
    
    private func updateCollapseState() {
        // Update the grid visibility
        self.gridStackView.alpha = self.isCollapsed ? 0 : 1
        
        UIView.animate(withDuration: 0.3) {
            if self.isCollapsed {
                // Activate height constraint when collapsing
                self.gridStackViewHeightConstraint.isActive = true
                self.gridStackViewBottomConstraint.constant = 0
            } else {
                // Deactivate height constraint when expanding
                self.gridStackViewHeightConstraint.isActive = false
                self.gridStackViewBottomConstraint.constant = -16
            }
            
            // Update the arrow
            let transform = self.isCollapsed ? CGAffineTransform(rotationAngle: .pi) : .identity
            self.collapseButton.transform = transform
            
        } completion: { _ in
            // Hide the grid after animation when collapsing
            self.gridStackView.isHidden = self.isCollapsed
            // Force layout update
            self.layoutIfNeeded()
            self.superview?.layoutIfNeeded()
        }
    }
    
}

#if DEBUG
import SwiftUI

@available(iOS 17.0, *)
struct GamesView_Preview: PreviewProvider {
    static var previews: some View {
        PreviewUIView {
            // Create container view with gray background
            let containerView = UIView()
            containerView.backgroundColor = .systemGray5 // or your preferred gray color
            
            let sportFilters = [
                SportFilter(id: "1", title: "Football", icon: "sportscourt.fill"),
                SportFilter(id: "2", title: "Basketball", icon: "basketball.fill"),
                SportFilter(id: "3", title: "Tennis", icon: "tennis.racket"),
                SportFilter(id: "4",title: "Cricket", icon: "figure.cricket")
            ]
            
            let viewModel = MockSportGamesFilterViewModel(title: "Games", sportFilters: sportFilters, selectedId: "1")
            let gamesView = SportGamesFilterView(viewModel: viewModel)
            
            // Add gamesView to container with constraints
            containerView.addSubview(gamesView)
            gamesView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                gamesView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
                gamesView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
                gamesView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16)
            ])
            
            return containerView
        }
        .frame(height: 300)
        .background(Color(uiColor: .systemGray5)) // Also set background for the SwiftUI container
    }
}
#endif
