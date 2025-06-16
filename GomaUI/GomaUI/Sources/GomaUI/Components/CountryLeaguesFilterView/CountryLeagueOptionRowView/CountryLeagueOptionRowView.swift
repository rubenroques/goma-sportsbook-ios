//
//  CountryLeagueOptionRowView.swift
//  GomaUI
//
//  Created by André Lascas on 27/05/2025.
//

import Foundation
import UIKit
import Combine

public class CountryLeagueOptionRowView: UIView {
    // MARK: - Properties
    private let headerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let leftIndicatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = StyleProvider.Color.highlightPrimary
        view.isHidden = true
        return view
    }()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .regular, size: 14)
        label.textColor = StyleProvider.Color.textPrimary
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }()
    
    private let countLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .regular, size: 12)
        label.textColor = StyleProvider.Color.textPrimary
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
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
        
    public var isSelected: Bool = false {
        didSet {
            updateSelectedState()
        }
    }
    
    private var isCollapsed: Bool = false {
        didSet {
            updateCollapseState()
        }
    }
    
    private var cancellables = Set<AnyCancellable>()
    private var leagueRows: [LeagueOptionSelectionRowView] = []

    public let viewModel: CountryLeagueOptionRowViewModelProtocol
    public var didTappedOption: ((Int) -> Void)?
        
    // MARK: - Initialization
    public init(viewModel: CountryLeagueOptionRowViewModelProtocol) {
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
        addSubview(headerView)
        
        headerView.addSubview(leftIndicatorView)
        headerView.addSubview(iconImageView)
        headerView.addSubview(titleLabel)
        headerView.addSubview(countLabel)
        headerView.addSubview(collapseButton)
        
        addSubview(stackView)
        
        stackViewBottomConstraint = stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0)
        stackViewHeightConstraint = stackView.heightAnchor.constraint(equalToConstant: 0)
        stackViewHeightConstraint.isActive = false
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: topAnchor),
            headerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            leftIndicatorView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            leftIndicatorView.topAnchor.constraint(equalTo: headerView.topAnchor),
            leftIndicatorView.bottomAnchor.constraint(equalTo: headerView.bottomAnchor),
            leftIndicatorView.widthAnchor.constraint(equalToConstant: 4),
            
            iconImageView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            iconImageView.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 12),
            iconImageView.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -12),
            iconImageView.widthAnchor.constraint(equalToConstant: 16),
            iconImageView.heightAnchor.constraint(equalToConstant: 16),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 8),
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            
            countLabel.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 4),
            countLabel.trailingAnchor.constraint(equalTo: collapseButton.leadingAnchor, constant: -4),
            countLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            
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
    
    private func updateSelection(forOptionId id: Int) {
        leagueRows.forEach { row in
            
            let leagueOption = row.viewModel.leagueOption
//            print("LEAGUE OPTION: \(id)")
            if leagueOption.id == id {
                row.isSelected = true
            }
            else {
                row.isSelected = false
            }
            
        }
        
        self.didTappedOption?(id)
    }
    
    private func updateSelectedState() {
        headerView.backgroundColor = isSelected ? StyleProvider.Color.separatorLine : .clear

        leftIndicatorView.isHidden = !isSelected
        
        iconImageView.tintColor = isSelected ? StyleProvider.Color.highlightPrimary : .black
        
        titleLabel.font = isSelected ? StyleProvider.fontWith(type: .bold, size: 14) : StyleProvider.fontWith(type: .regular, size: 14)
        
        countLabel.font = isSelected ? StyleProvider.fontWith(type: .bold, size: 12) : StyleProvider.fontWith(type: .regular, size: 12)
        countLabel.textColor = isSelected ? StyleProvider.Color.highlightPrimary : StyleProvider.Color.textPrimary

    }
    
    @objc private func collapseButtonTapped() {
        self.viewModel.toggleCollapse()
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
    
    
    // MARK: - Public Methods
    public func configure() {
        backgroundColor = isSelected ? StyleProvider.Color.separatorLine : .clear
        leftIndicatorView.isHidden = !isSelected
        iconImageView.image = UIImage(named: self.viewModel.countryLeagueOptions.icon ?? "")
        iconImageView.tintColor = isSelected ? StyleProvider.Color.highlightPrimary : .black
        titleLabel.text = self.viewModel.countryLeagueOptions.title
        
        let totalEvents = self.viewModel.countryLeagueOptions.leagues.compactMap { league in
            league.count
        }.reduce(0, +) // Combine all values into a single value

        countLabel.text = totalEvents > 0 ? String(totalEvents) : "No Events"
        
        for league in self.viewModel.countryLeagueOptions.leagues {
            let rowViewModel = MockLeagueOptionSelectionRowViewModel(leagueOption: league)
            let row = LeagueOptionSelectionRowView(viewModel: rowViewModel)
            row.translatesAutoresizingMaskIntoConstraints = false
            row.heightAnchor.constraint(equalToConstant: 56).isActive = true
            row.configure(selectedLeagueId: viewModel.selectedOptionId.value)
            
            row.didTappedOption = { [weak self] tappedOption in
                self?.viewModel.selectOption(withId: tappedOption.id)
            }
            
            leagueRows.append(row)
            stackView.addArrangedSubview(row)
            
        }
    }
    
    public func updateLeagueSelectionId(leagueId: Int) {
        if self.viewModel.selectedOptionId.value != leagueId {
            self.viewModel.selectOption(withId: leagueId)
        }
    }
    
}
