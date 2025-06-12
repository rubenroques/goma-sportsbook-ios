//
//  LeaguesFilterView.swift
//  GomaUI
//
//  Created by André Lascas on 28/05/2025.
//

import Foundation

import UIKit
import Combine

public class LeaguesFilterView: UIView {
    // MARK: - Properties
    private let headerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Leagues"
        label.font = StyleProvider.fontWith(type: .bold, size: 14)
        label.textColor = StyleProvider.Color.textPrimary
        return label
    }()
    
    private let collapseButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let image = UIImage(systemName: "chevron.up")?.withRenderingMode(.alwaysTemplate)
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
    
    private var optionRows: [LeagueOptionRowView] = []
    private let viewModel: LeaguesFilterViewModelProtocol
    private var cancellables = Set<AnyCancellable>()
    
    private var isCollapsed: Bool = false {
        didSet {
            updateCollapseState()
        }
    }
    
    public var onLeagueFilterSelected: ((Int) -> Void)?

    // MARK: - Initialization
    public init(viewModel: LeaguesFilterViewModelProtocol) {
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
        setupOptions()
    }
    
    private func setupOptions() {
        optionRows.forEach { $0.removeFromSuperview() }
        optionRows.removeAll()
        
        for option in viewModel.leagueOptions {
            let row = LeagueOptionRowView()
            row.translatesAutoresizingMaskIntoConstraints = false
            row.heightAnchor.constraint(equalToConstant: 56).isActive = true
            row.configure(with: option)
            
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
    }
    
    // MARK: - Actions
    @objc private func collapseButtonTapped() {
        viewModel.toggleCollapse()
    }
    
    private func updateSelection(forOptionId id: Int) {
        optionRows.forEach { row in
            if let option = row.leagueOption {
                row.isSelected = option.id == id
            }
        }
        
        self.onLeagueFilterSelected?(id)
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
            
            // Force layout update
            self.layoutIfNeeded()
            self.superview?.layoutIfNeeded()
        } completion: { _ in
            // Hide the grid after animation when collapsing
            self.stackView.isHidden = self.isCollapsed
        }
    }
}

#if DEBUG
import SwiftUI

@available(iOS 17.0, *)
struct LeaguesFilterView_Preview: PreviewProvider {
    static var previews: some View {
        PreviewUIView {
            let containerView = UIView()
            containerView.backgroundColor = .systemGray6
            
            let leagueOptions = [
                LeagueOption(
                    id: 1,
                    icon: "trophy.fill",
                    title: "Premier League",
                    count: 32
                ),
                LeagueOption(
                    id: 2,
                    icon: "trophy.fill",
                    title: "La Liga",
                    count: 28
                ),
                LeagueOption(
                    id: 3,
                    icon: "trophy.fill",
                    title: "Bundesliga",
                    count: 25
                ),
                LeagueOption(
                    id: 4,
                    icon: "trophy.fill",
                    title: "Serie A",
                    count: 27
                ),
                LeagueOption(
                    id: 5,
                    icon: "trophy.fill",
                    title: "Ligue 1",
                    count: 0
                ),
                LeagueOption(
                    id: 6,
                    icon: "trophy.fill",
                    title: "Champions League",
                    count: 16
                ),
                LeagueOption(
                    id: 7,
                    icon: "trophy.fill",
                    title: "Europa League",
                    count: 12
                ),
                LeagueOption(
                    id: 8,
                    icon: "trophy.fill",
                    title: "MLS",
                    count: 28
                ),
                LeagueOption(
                    id: 9,
                    icon: "trophy.fill",
                    title: "Eredivisie",
                    count: 18
                ),
                LeagueOption(
                    id: 10,
                    icon: "trophy.fill",
                    title: "Primeira Liga",
                    count: 16
                )
            ]
            
            let viewModel = MockLeaguesFilterViewModel(leagueOptions: leagueOptions)
            let leaguesFilterView = LeaguesFilterView(viewModel: viewModel)
            
            containerView.addSubview(leaguesFilterView)
            leaguesFilterView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                leaguesFilterView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 60),
                leaguesFilterView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
                leaguesFilterView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16)
            ])
            
            return containerView
        }
        .frame(height: 900)
        .background(Color(uiColor: .systemGray6))
    }
}
#endif
