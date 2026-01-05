import Foundation

import UIKit
import Combine

public class CountryLeaguesFilterView: UIView {
    // MARK: - Properties
    private let headerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = LocalizationProvider.string("popular_countries")
        label.font = StyleProvider.fontWith(type: .bold, size: 14)
        label.textColor = StyleProvider.Color.textPrimary
        return label
    }()
    
    private let collapseIconView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        if let customImage = UIImage(named: "chevron_up_icon")?.withRenderingMode(.alwaysTemplate) {
            imageView.image = customImage
        }
        else if let systemImage = UIImage(systemName: "chevron.down")?.withRenderingMode(.alwaysTemplate) {
            imageView.image = systemImage
        }
        imageView.tintColor = StyleProvider.Color.iconPrimary
        return imageView
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
    
    private var countryRows: [CountryLeagueOptionRowView] = []
    private let viewModel: CountryLeaguesFilterViewModelProtocol
    private var cancellables = Set<AnyCancellable>()
    
    private var isCollapsed: Bool = false {
        didSet {
            updateCollapseState()
        }
    }
    
    public var onLeagueFilterSelected: ((String) -> Void)?

    // MARK: - Initialization
    public init(viewModel: CountryLeaguesFilterViewModelProtocol) {
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
        backgroundColor = StyleProvider.Color.backgroundTertiary
        layer.cornerRadius = 0
        
        addSubview(headerView)
        headerView.addSubview(titleLabel)
        headerView.addSubview(collapseIconView)
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

            collapseIconView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -21),
            collapseIconView.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            collapseIconView.widthAnchor.constraint(equalToConstant: 14),
            collapseIconView.heightAnchor.constraint(equalToConstant: 14),
            
            stackView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackViewBottomConstraint
        ])

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(headerTapped))
        headerView.addGestureRecognizer(tapGesture)
        headerView.isUserInteractionEnabled = true

        self.titleLabel.text = viewModel.title
        
        setupOptions()
    }
    
    private func setupOptions() {
        countryRows.forEach { $0.removeFromSuperview() }
        countryRows.removeAll()
        
        let selectedLeagueId = viewModel.selectedOptionId.value

        for countryLeagueOption in viewModel.countryLeagueOptions {
            
            var isCollapsed = countryLeagueOption.leagues.contains(where: {
                $0.id == selectedLeagueId
            }) ? true : false

            let viewModel = MockCountryLeagueOptionRowViewModel(countryLeaguesOptions: countryLeagueOption, selectedLeagueId: selectedLeagueId)
            
            let row = CountryLeagueOptionRowView(viewModel: viewModel)
            
            row.translatesAutoresizingMaskIntoConstraints = false
            
            row.didTappedOption = { [weak self] leagueOption in
                self?.viewModel.selectedOptionId.send(leagueOption)
            }
                        
            row.configure()
            countryRows.append(row)
            stackView.addArrangedSubview(row)
        }
    }
    
    private func updateViewModels(id: String) {
        countryRows.forEach( { row in
            row.updateLeagueSelectionId(leagueId: id)
        })
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
//                print("UPDATE COUNTRY LEAGUES UI!")
                self?.setupOptions()
                if let selectedOptionId = self?.viewModel.selectedOptionId.value {
                    self?.viewModel.selectedOptionId.send(selectedOptionId)
                }
            })
            .store(in: &cancellables)
    }
    
    // MARK: - Actions
    @objc private func headerTapped() {
        viewModel.toggleCollapse()
    }
    
    private func updateSelection(forOptionId id: String) {
        countryRows.forEach { row in
            
            let option = row.viewModel.countryLeagueOptions
            
            // Always clear selection first, then set if league exists in this country
            row.isSelected = false
            
            // Only mark as selected if the league exists in this country's leagues
            if option.leagues.contains(where: { $0.id == id }) {
                row.isSelected = true
            }
        }
        
        self.updateViewModels(id: id)
        
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
            self.collapseIconView.transform = transform
            
            
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
struct CountryLeaguesFilterView_Preview: PreviewProvider {
    static var previews: some View {
        PreviewUIView {
            let containerView = UIView()
            containerView.backgroundColor = .systemGray6
            
            let countryLeagueOptions = [
                CountryLeagueOptions(
                    id: "1",
                    icon: "england_flag",
                    title: "England",
                    leagues: [
                        LeagueOption(id: "1", icon: nil, title: "Premier League", count: 25),
                        LeagueOption(id: "2", icon: nil, title: "Championship", count: 24),
                        LeagueOption(id: "3", icon: nil, title: "League One", count: 22),
                        LeagueOption(id: "4", icon: nil, title: "League Two", count: 0),
                        LeagueOption(id: "5", icon: nil, title: "FA Cup", count: 18),
                        LeagueOption(id: "6", icon: nil, title: "EFL Cup", count: 16)
                    ],
                    isExpanded: true
                ),
                CountryLeagueOptions(
                    id: "2",
                    icon: "france_flag",
                    title: "France",
                    leagues: [
                        LeagueOption(id: "7", icon: nil, title: "Ligue 1", count: 20),
                        LeagueOption(id: "8", icon: nil, title: "Ligue 2", count: 18),
                        LeagueOption(id: "9", icon: nil, title: "Coupe de France", count: 12)
                    ],
                    isExpanded: false
                ),
                CountryLeagueOptions(
                    id: "3",
                    icon: "germany_flag",
                    title: "Germany",
                    leagues: [
                        LeagueOption(id: "10", icon: nil, title: "Bundesliga", count: 18),
                        LeagueOption(id: "11", icon: nil, title: "2. Bundesliga", count: 18),
                        LeagueOption(id: "12", icon: nil, title: "DFB-Pokal", count: 14)
                    ],
                    isExpanded: false
                ),
                CountryLeagueOptions(
                    id: "4",
                    icon: "italy_flag",
                    title: "Italy",
                    leagues: [
                        LeagueOption(id: "13", icon: nil, title: "Serie A", count: 20),
                        LeagueOption(id: "14", icon: nil, title: "Serie B", count: 20),
                        LeagueOption(id: "15", icon: nil, title: "Coppa Italia", count: 16)
                    ],
                    isExpanded: false
                ),
                CountryLeagueOptions(
                    id: "5",
                    icon: "spain_flag",
                    title: "Spain",
                    leagues: [
                        LeagueOption(id: "16", icon: nil, title: "La Liga", count: 20),
                        LeagueOption(id: "17", icon: nil, title: "La Liga 2", count: 22),
                        LeagueOption(id: "18", icon: nil, title: "Copa del Rey", count: 15)
                    ],
                    isExpanded: false
                ),
                CountryLeagueOptions(
                    id: "6",
                    icon: "international_flag",
                    title: "International",
                    leagues: [
                        LeagueOption(id: "19", icon: nil, title: "Champions League", count: 32),
                        LeagueOption(id: "20", icon: nil, title: "Europa League", count: 24),
                        LeagueOption(id: "21", icon: nil, title: "Conference League", count: 18),
                        LeagueOption(id: "22", icon: nil, title: "World Cup Qualifiers", count: 28),
                        LeagueOption(id: "23", icon: nil, title: "Nations League", count: 16)
                    ],
                    isExpanded: false
                )
            ]
            
            let viewModel = MockCountryLeaguesFilterViewModel(title: "Popular Countries", countryLeagueOptions: countryLeagueOptions)
            let countryLeaguesFilterView = CountryLeaguesFilterView(viewModel: viewModel)
            
            containerView.addSubview(countryLeaguesFilterView)
            countryLeaguesFilterView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                countryLeaguesFilterView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 60),
                countryLeaguesFilterView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
                countryLeaguesFilterView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16)
            ])
            
            return containerView
        }
        .frame(height: 900)
        .background(Color(uiColor: .systemGray6))
    }
}
#endif
