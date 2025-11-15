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
    public var didTappedOption: ((String) -> Void)?
        
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
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        iconImageView.layer.cornerRadius = iconImageView.frame.height / 2
        iconImageView.clipsToBounds = true
    }
    
    // MARK: - Setup
    private func setupView() {
        addSubview(headerView)
        
        headerView.addSubview(leftIndicatorView)
        headerView.addSubview(iconImageView)
        headerView.addSubview(titleLabel)
        headerView.addSubview(countLabel)
        headerView.addSubview(collapseIconView)
        
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
            countLabel.trailingAnchor.constraint(equalTo: collapseIconView.leadingAnchor, constant: -4),
            countLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),

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

        self.setNeedsLayout()
        self.layoutIfNeeded()
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
    
    private func updateSelection(forOptionId id: String) {
        // Check if "All" option is selected (ends with "_all")
        let isAllSelected = id.hasSuffix("_all")
        let countryId = viewModel.countryLeagueOptions.id
        
        // Check if the selected league belongs to this country
        let leagueBelongsToThisCountry = viewModel.countryLeagueOptions.leagues.contains { $0.id == id }
        
        leagueRows.forEach { row in
            let leagueOption = row.viewModel.leagueOption
            
            if !leagueBelongsToThisCountry {
                // If league doesn't belong to this country, deselect all
                row.isSelected = false
            } else if isAllSelected && id == "\(countryId)_all" {
                // If "All" is selected for this country, only select the "All" option
                row.isSelected = (leagueOption.id == id)
            } else if leagueOption.id == id {
                // Individual league selected
                row.isSelected = true
            } else if leagueOption.id == "\(countryId)_all" {
                // Deselect "All" when individual league is selected
                row.isSelected = false
            } else {
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
    
    @objc private func headerTapped() {
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
            self.collapseIconView.transform = transform
            
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
        
        // TODO: Enable Kingfisher later
//        if let flagIconUrl = self.flagIconURL(for: self.viewModel.countryLeagueOptions.icon ?? "") {
//            iconImageView.kf.setImage(with: flagIconUrl)
//
//        }
//        else {
//            iconImageView.image = UIImage(named: "country_flag_240")
//        }
        
        loadFlagImage(for: self.viewModel.countryLeagueOptions.icon ?? "") { image in
            if let image {
                self.iconImageView.image = image
            }
            else {
                self.iconImageView.image = UIImage(systemName: "globe")
            }
        }

        iconImageView.tintColor = isSelected ? StyleProvider.Color.highlightPrimary : .black
        titleLabel.text = self.viewModel.countryLeagueOptions.title
        
        let totalEvents = self.viewModel.countryLeagueOptions.leagues
            .filter { !$0.isAllOption }
            .compactMap { league in
                league.count
            }.reduce(0, +)

        countLabel.text = totalEvents > 0 ? String(totalEvents) : "No Events"
        
        for league in self.viewModel.countryLeagueOptions.leagues {
            let rowViewModel = MockLeagueOptionSelectionRowViewModel(leagueOption: league)
            let row = LeagueOptionSelectionRowView(viewModel: rowViewModel)
            row.translatesAutoresizingMaskIntoConstraints = false
            row.heightAnchor.constraint(equalToConstant: 56).isActive = true
            row.configure(selectedLeagueId: viewModel.selectedOptionId.value)
            
            row.didTappedOption = { [weak self] tappedOption in
                guard let self = self else { return }
                
                // Handle "All" option selection logic
                let countryId = self.viewModel.countryLeagueOptions.id
                let allOptionId = "\(countryId)_all"
                
                if tappedOption.id == allOptionId {
                    // "All" was tapped - select it exclusively
                    self.viewModel.selectOption(withId: tappedOption.id)
                } else {
                    // Individual league was tapped
                    // This will automatically deselect "All" in updateSelection
                    self.viewModel.selectOption(withId: tappedOption.id)
                }
            }
            
            leagueRows.append(row)
            stackView.addArrangedSubview(row)
            
        }
    }
    
    public func updateLeagueSelectionId(leagueId: String) {
        if self.viewModel.selectedOptionId.value != leagueId {
            self.viewModel.selectOption(withId: leagueId)
        }
    }
    
    func flagIconURL(for venueId: String) -> URL? {
        return URL(string:"https://static.glastcoper.com/omfe-widgets/s/assets/1.10.2/om1/icons/flag/\(venueId).png")
    }
    
    func loadFlagImage(for venueId: String, completion: @escaping (UIImage?) -> Void) {
        let urlString = "https://static.glastcoper.com/omfe-widgets/s/assets/1.10.2/om1/icons/flag/\(venueId).png"
        guard let url = URL(string: urlString) else {
            DispatchQueue.main.async {
                completion(nil)
            }
            return
        }
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, let image = UIImage(data: data), error == nil else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            DispatchQueue.main.async {
                completion(image)
            }
        }.resume()
    }
}
