//
//  SortFilterView.swift
//  GomaUI
//
//  Created by André Lascas on 27/05/2025.
//

import Foundation
import UIKit
import Combine

public class SortFilterView: UIView {
    // MARK: - Properties
    private let headerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Sort By"
        label.font = StyleProvider.fontWith(type: .bold, size: 14)
        label.textColor = StyleProvider.Color.textPrimary
        return label
    }()
    
    private let collapseButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let image = UIImage(systemName: "chevron.down")?.withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.tintColor = .black
        return button
    }()
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 0
        return stack
    }()
    
    // Constraints
    private var stackViewBottomConstraint: NSLayoutConstraint = {
        NSLayoutConstraint()
    }()
    
    private var stackViewHeightConstraint: NSLayoutConstraint = {
        NSLayoutConstraint()
    }()
    
    private var optionRows: [SortOptionRowView] = []
    private let viewModel: SortFilterViewModelProtocol
    private var cancellables = Set<AnyCancellable>()
    
    private var isCollapsed: Bool = false {
        didSet {
            updateCollapseState()
        }
    }
    
    public var onSortFilterSelected: ((String) -> Void)?

    // MARK: - Initialization
    public init(viewModel: SortFilterViewModelProtocol) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupView()
        setupBindings()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupView() {
        backgroundColor = .white
        layer.cornerRadius = 0
        
        addSubview(headerView)
        headerView.addSubview(titleLabel)
        headerView.addSubview(collapseButton)
        addSubview(stackView)
        
        stackViewBottomConstraint = stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0)
        stackViewHeightConstraint = stackView.heightAnchor.constraint(equalToConstant: 0)
        stackViewHeightConstraint.isActive = false
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: topAnchor),
            headerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 12),
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            
            collapseButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            collapseButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            collapseButton.widthAnchor.constraint(equalToConstant: 24),
            collapseButton.heightAnchor.constraint(equalToConstant: 24),
            
            stackView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackViewBottomConstraint
        ])
        
        collapseButton.addTarget(self, action: #selector(collapseButtonTapped), for: .touchUpInside)
        
        self.titleLabel.text = viewModel.title
        
        setupOptions()
    }
    
    private func setupOptions() {
        optionRows.forEach { $0.removeFromSuperview() }
        optionRows.removeAll()
        
        for option in viewModel.sortOptions {
            let rowViewModel = MockSortOptionRowViewModel(sortOption: option)
            let row = SortOptionRowView(viewModel: rowViewModel)
            row.translatesAutoresizingMaskIntoConstraints = false
            row.heightAnchor.constraint(equalToConstant: 56).isActive = true
            row.configure()
            
            row.didTappedOption = { [weak self] tappedOption in
                self?.viewModel.selectOption(withId: tappedOption.id)
            }
            
            optionRows.append(row)
            stackView.addArrangedSubview(row)
        }
    }
    
    private func setupBindings() {
        viewModel.selectedOptionId
            .sink { [weak self] optionId in
                self?.updateSelection(forOptionId: optionId)
            }
            .store(in: &cancellables)
        
        viewModel.isCollapsed
            .sink { [weak self] isCollapsed in
                self?.isCollapsed = isCollapsed
                
                self?.updateCollapseState()
            }
            .store(in: &cancellables)
        
        viewModel.shouldRefreshData
            .sink(receiveValue: { [weak self] in
                self?.setupOptions()
                if let selectedOption = self?.viewModel.selectedOptionId.value {
                    self?.viewModel.selectOption(withId: selectedOption)
                }
            })
            .store(in: &cancellables)
    }
    
    // MARK: - Actions
    @objc private func collapseButtonTapped() {
        viewModel.toggleCollapse()
    }
    
    private func updateSelection(forOptionId id: String) {
        
        optionRows.forEach { row in
            let option = row.viewModel.sortOption
            row.isSelected = option.id == id
            
        }
        
        self.onSortFilterSelected?(id)

    }
    
    private func updateCollapseState() {
        self.stackView.alpha = self.isCollapsed ? 0 : 1
        
        UIView.animate(withDuration: 0.3) {
            if self.isCollapsed {
                self.stackViewHeightConstraint.isActive = true
            } else {
                
                self.stackViewHeightConstraint.isActive = false
            }
            
            // Update the arrow
            let transform = self.isCollapsed ? CGAffineTransform(rotationAngle: .pi) : .identity
            self.collapseButton.transform = transform
            
        } completion: { _ in
            // Hide the grid after animation when collapsing
            self.stackView.isHidden = self.isCollapsed
            // Force layout update
            self.layoutIfNeeded()
            self.superview?.layoutIfNeeded()
        }
    }
}

#if DEBUG
import SwiftUI

@available(iOS 17.0, *)
struct SortByView_Preview: PreviewProvider {
    static var previews: some View {
        PreviewUIView {
            let containerView = UIView()
            containerView.backgroundColor = .systemGray6
            
            let sortOptions: [SortOption] = [
                SortOption(id: "1", icon: "flame.fill", title: "Popular", count: 25),
                SortOption(id: "2", icon: "clock.fill", title: "Upcoming", count: 15),
                SortOption(id: "3", icon: "heart.fill", title: "Favourites", count: 0)
            ]
            
            let viewModel = MockSortFilterViewModel(title: "Sort By", sortOptions: sortOptions)
            let sortByView = SortFilterView(viewModel: viewModel)
            
            containerView.addSubview(sortByView)
            sortByView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                sortByView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
                sortByView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
                sortByView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16)
            ])
            
            return containerView
        }
        .frame(height: 300)
        .background(Color(uiColor: .systemGray6))
    }
}
#endif
