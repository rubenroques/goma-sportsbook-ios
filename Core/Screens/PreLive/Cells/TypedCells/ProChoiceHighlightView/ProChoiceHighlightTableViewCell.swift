//
//  ProChoiceHighlightTableViewCell.swift
//  GomaUI
//
//  Created by Ruben Roques on 15/10/2024.
//
import UIKit
import Kingfisher

class ProChoiceHighlightTableViewCell: UITableViewCell {
    
    // MARK: - UI Components
    private lazy var containerView: UIView = self.createContainerView()

    private lazy var containerStackView: UIStackView = self.createContainerStackView()

    // New UI components
    private lazy var eventImageView: UIImageView = self.createEventImageView()

    private lazy var leagueInfoContainerView: UIView = self.createLeagueInfoContainerView()
    private lazy var leagueInfoStackView: UIStackView = self.createLeagueInfoStackView()

    private lazy var favoriteImageView: UIImageView = self.createIconImageView()
    private lazy var sportImageView: UIImageView = self.createIconImageView()
    private lazy var countryImageView: UIImageView = self.createIconImageView()
    private lazy var leagueNameLabel: UILabel = self.createLeagueNameLabel()
    private lazy var cashbackImageView: UIImageView = self.createIconImageView()

    private lazy var topSeparatorAlphaLineView: FadingView = self.createTopSeparatorAlphaLineView()

    private lazy var eventInfoContainerView: UIView = self.createLeagueInfoContainerView()

    private lazy var eventDateLabel: UILabel = self.createEventDateLabel()
    private lazy var eventTimeLabel: UILabel = self.createEventTimeLabel()
    private lazy var marketNameLabel: UILabel = self.createMarketNameLabel()

    private lazy var teamPillContainerView: UIView = self.createTeamPillContainerView()
    private lazy var teamsLabel: UILabel = self.createTeamsLabel()

    private lazy var oddsStackView: UIStackView = self.createOddsStackView()

    private lazy var homeButton: UIView = self.createOutcomeBaseView()
    private lazy var homeOutcomeNameLabel: UILabel = self.createOutcomeNameLabel()
    private lazy var homeOutcomeValueLabel: UILabel = self.createOutcomeValueLabel()

    private lazy var drawButton: UIView = self.createOutcomeBaseView()
    private lazy var awayButton: UIView = self.createOutcomeBaseView()

    private lazy var bottomButtonsContainerStackView: UIStackView = self.createBottomButtonsContainerStackView()
    private lazy var seeAllMarketsButton: UIButton = self.createSeeAllMarketsButton()

    private var viewModel: ProChoiceHighlightViewModel = .empty

    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.setupSubviews()
        self.setupWithTheme()

#if DEBUG
        self.homeButton.backgroundColor = .darkGray
        self.containerView.backgroundColor = .white
        self.eventInfoContainerView.backgroundColor = .blue
        self.teamPillContainerView.backgroundColor = .brown
#endif
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Reuse
    override func prepareForReuse() {
        super.prepareForReuse()

        self.viewModel = .empty
    }

    // MARK: - Configuration
    private func setupWithTheme() {
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear

        self.containerView.backgroundColor = UIColor.App.backgroundPrimary

        self.leagueNameLabel.textColor = UIColor.App.textPrimary
        self.eventDateLabel.textColor = UIColor.App.textPrimary
        self.eventTimeLabel.textColor = UIColor.App.textPrimary
        self.teamsLabel.textColor = UIColor.App.textPrimary
    }

    func configure(with viewModel: ProChoiceHighlightViewModel) {
        self.viewModel = viewModel
        
        // New configuration
        self.leagueNameLabel.text = viewModel.leagueName
        self.eventDateLabel.text = viewModel.matchDate
        self.eventTimeLabel.text = viewModel.matchTime
        self.teamsLabel.text = viewModel.teamsName
        
        // Configure odds buttons
        self.configureOddsButtons(home: viewModel.homeOdds, draw: viewModel.drawOdds, away: viewModel.awayOdds)

        self.leagueNameLabel.text = viewModel.leagueName

        self.eventImageView.image = UIImage(named: "dummyPlaceholder")
        self.favoriteImageView.image = UIImage(named: "selected_favorite_icon")
    }
    
    private func configureOddsButtons(home: String?, draw: String?, away: String?) {
        self.homeButton.isHidden = home == nil
        self.drawButton.isHidden = draw == nil
        self.awayButton.isHidden = away == nil
    }
    
    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()

        self.teamPillContainerView.layer.cornerRadius = self.teamPillContainerView.frame.height/2
        self.sportImageView.layer.cornerRadius = self.sportImageView.frame.height/2
        self.countryImageView.layer.cornerRadius = self.countryImageView.frame.height/2
    }

}

extension ProChoiceHighlightTableViewCell {
    
    // MARK: - UI Setup
    private func setupSubviews() {
        self.contentView.addSubview(self.containerView)
        self.containerView.addSubview(self.containerStackView)

        self.containerStackView.addArrangedSubview(self.eventImageView)

        self.containerStackView.addArrangedSubview(self.leagueInfoContainerView)
        self.leagueInfoContainerView.addSubview(self.leagueInfoStackView)

        self.leagueInfoStackView.addArrangedSubview(self.favoriteImageView)

        self.leagueInfoStackView.addArrangedSubview(self.favoriteImageView)
        self.leagueInfoStackView.addArrangedSubview(self.sportImageView)
        self.leagueInfoStackView.addArrangedSubview(self.countryImageView)
        self.leagueInfoStackView.addArrangedSubview(self.leagueNameLabel)
        self.leagueInfoContainerView.addSubview(self.cashbackImageView)

        self.containerStackView.addArrangedSubview(self.topSeparatorAlphaLineView)
        self.containerStackView.addArrangedSubview(self.eventInfoContainerView)

        self.containerStackView.addArrangedSubview(self.oddsStackView)
        self.oddsStackView.addArrangedSubview(self.homeButton)
        self.oddsStackView.addArrangedSubview(self.drawButton)
        self.oddsStackView.addArrangedSubview(self.awayButton)


        self.containerStackView.addArrangedSubview(self.bottomButtonsContainerStackView)
        self.bottomButtonsContainerStackView.addArrangedSubview(self.seeAllMarketsButton)

        self.teamPillContainerView.addSubview(self.teamsLabel)
        self.eventInfoContainerView.addSubview(self.teamPillContainerView)
        self.eventInfoContainerView.addSubview(self.marketNameLabel)
        self.eventInfoContainerView.addSubview(self.eventDateLabel)
        self.eventInfoContainerView.addSubview(self.eventTimeLabel)

        self.homeButton.addSubview(self.homeOutcomeNameLabel)
        self.homeButton.addSubview(self.homeOutcomeValueLabel)

        //

        self.oddsStackView.layoutMargins = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)

        self.bottomButtonsContainerStackView.isLayoutMarginsRelativeArrangement = true
        self.bottomButtonsContainerStackView.layoutMargins = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        //

        self.initConstraints()
    }
    
    private func initConstraints() {
        NSLayoutConstraint.activate([
            self.containerView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 8),
            self.containerView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 16),
            self.containerView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -16),
            self.containerView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -8),

            self.containerStackView.topAnchor.constraint(equalTo: self.containerView.topAnchor),
            self.containerStackView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
            self.containerStackView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor),
            self.containerStackView.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor, constant: -8),

            self.eventImageView.heightAnchor.constraint(equalToConstant: 100),

            self.leagueInfoStackView.heightAnchor.constraint(equalToConstant: 14),
            self.leagueInfoStackView.leadingAnchor.constraint(equalTo: self.leagueInfoContainerView.leadingAnchor, constant: 16),
            self.leagueInfoStackView.trailingAnchor.constraint(equalTo: self.leagueInfoContainerView.trailingAnchor, constant: -16),
            self.leagueInfoStackView.topAnchor.constraint(equalTo: self.leagueInfoContainerView.topAnchor, constant: 8),
            self.leagueInfoStackView.bottomAnchor.constraint(equalTo: self.leagueInfoContainerView.bottomAnchor, constant: -8),

            self.favoriteImageView.widthAnchor.constraint(equalTo: self.favoriteImageView.heightAnchor),
            self.sportImageView.widthAnchor.constraint(equalTo: self.sportImageView.heightAnchor),
            self.countryImageView.widthAnchor.constraint(equalTo: self.countryImageView.heightAnchor),

            self.cashbackImageView.centerYAnchor.constraint(equalTo: self.leagueInfoContainerView.centerYAnchor),
            self.cashbackImageView.trailingAnchor.constraint(equalTo: self.leagueInfoContainerView.trailingAnchor),
            self.cashbackImageView.widthAnchor.constraint(equalToConstant: 14),
            self.cashbackImageView.widthAnchor.constraint(equalTo: self.cashbackImageView.heightAnchor),

            self.eventInfoContainerView.heightAnchor.constraint(equalToConstant: 70),

            self.marketNameLabel.leadingAnchor.constraint(equalTo: self.eventInfoContainerView.leadingAnchor, constant: 16),
            self.marketNameLabel.topAnchor.constraint(equalTo: self.eventInfoContainerView.topAnchor, constant: 8),

            self.teamsLabel.topAnchor.constraint(equalTo: self.teamPillContainerView.topAnchor, constant: 5),
            self.teamsLabel.bottomAnchor.constraint(equalTo: self.teamPillContainerView.bottomAnchor, constant: -5),
            self.teamsLabel.trailingAnchor.constraint(equalTo: self.teamPillContainerView.trailingAnchor, constant: -9),
            self.teamsLabel.leadingAnchor.constraint(equalTo: self.teamPillContainerView.leadingAnchor, constant: 40),

            self.teamsLabel.leadingAnchor.constraint(equalTo: self.eventInfoContainerView.leadingAnchor, constant: 16),
            self.teamPillContainerView.bottomAnchor.constraint(equalTo: self.eventInfoContainerView.bottomAnchor, constant: -8),

            self.eventDateLabel .lastBaselineAnchor.constraint(equalTo: self.marketNameLabel.firstBaselineAnchor),
            self.eventDateLabel.trailingAnchor.constraint(equalTo: self.eventInfoContainerView.trailingAnchor, constant: -16),

            self.eventTimeLabel.lastBaselineAnchor.constraint(equalTo: self.teamsLabel.firstBaselineAnchor),
            self.eventTimeLabel.trailingAnchor.constraint(equalTo: self.eventInfoContainerView.trailingAnchor, constant: -16),

            self.homeButton.heightAnchor.constraint(equalToConstant: 38),
            self.drawButton.heightAnchor.constraint(equalTo: self.homeButton.heightAnchor),
            self.awayButton.heightAnchor.constraint(equalTo: self.homeButton.heightAnchor),

            self.seeAllMarketsButton.heightAnchor.constraint(equalToConstant: 32)
        ])

        NSLayoutConstraint.activate([
            self.homeOutcomeNameLabel.centerXAnchor.constraint(equalTo: self.homeButton.centerXAnchor),
            self.homeOutcomeNameLabel.topAnchor.constraint(equalTo: self.homeButton.topAnchor, constant: 5),

            self.homeOutcomeValueLabel.centerXAnchor.constraint(equalTo: self.homeButton.centerXAnchor),
            self.homeOutcomeValueLabel.bottomAnchor.constraint(equalTo: self.homeButton.bottomAnchor, constant: -5),
        ])
    }

    // MARK: - UI Creation    
    private func createContainerView() -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor.App.backgroundPrimary
        view.layer.cornerRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        return view
    }

    private func createContainerStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.spacing = 0
        stackView.translatesAutoresizingMaskIntoConstraints = false

        stackView.backgroundColor = .green

        return stackView
    }

    private func createEventImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }

    private func createLeagueInfoContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private func createLeagueInfoStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.spacing = 6
        stackView.translatesAutoresizingMaskIntoConstraints = false

        stackView.backgroundColor = .red

        return stackView
    }

    private func createIconImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }

    private func createLeagueNameLabel() -> UILabel {
        let label = UILabel()
        label.font = AppFont.with(type: .medium, size: 11)
        label.textColor = UIColor.App.textPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    private func createEventDateLabel() -> UILabel {
        let label = UILabel()
        label.font = AppFont.with(type: .medium, size: 14)
        label.textColor = UIColor.App.textPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    private func createEventTimeLabel() -> UILabel {
        let label = UILabel()
        label.font = AppFont.with(type: .medium, size: 14)
        label.textColor = UIColor.App.textPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    private func createMarketNameLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .bold, size: 16)
        label.textColor = UIColor.App.textPrimary
        label.textAlignment = .center
        label.text = "Market Name Label"
        return label
    }

    private func createTeamPillContainerView() -> UIView {
        let view = UIView()
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private func createTeamsLabel() -> UILabel {
        let label = UILabel()
        label.font = AppFont.with(type: .bold, size: 11)
        label.textColor = UIColor.App.textPrimary
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    private func createOddsStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.isLayoutMarginsRelativeArrangement = true
        return stackView
    }
    
    private func createOutcomeBaseView() -> UIView {
        let outcomeBaseView = UIView()
        outcomeBaseView.translatesAutoresizingMaskIntoConstraints = false
        outcomeBaseView.layer.cornerRadius = 8
        return outcomeBaseView
    }

    private func createOutcomeNameLabel() -> UILabel {
        let outcomeNameLabel = UILabel()
        outcomeNameLabel.translatesAutoresizingMaskIntoConstraints = false
        outcomeNameLabel.text = "Atlético Madrid"
        outcomeNameLabel.textAlignment = .center
        outcomeNameLabel.font = AppFont.with(type: .medium, size: 8)
        return outcomeNameLabel
    }

    private func createOutcomeValueLabel() -> UILabel {
        let outcomeValueLabel = UILabel()
        outcomeValueLabel.translatesAutoresizingMaskIntoConstraints = false
        outcomeValueLabel.text = "1,29"
        outcomeValueLabel.textAlignment = .center
        outcomeValueLabel.font = AppFont.with(type: .bold, size: 14)
        return outcomeValueLabel
    }

    private func createBottomButtonsContainerStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false

        stackView.backgroundColor = .green

        return stackView
    }

    private func createSeeAllMarketsButton() -> UIButton {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.App.buttonBackgroundPrimary
        button.setTitle("See other markets", for: .normal)
        button.titleLabel?.font = AppFont.with(type: .bold, size: 16)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }

    private func createTopSeparatorAlphaLineView() -> FadingView {
        let fadingView = FadingView()
        fadingView.translatesAutoresizingMaskIntoConstraints = false
        fadingView.colors = [.clear, .black, .black, .clear]
        fadingView.startPoint = CGPoint(x: 0.0, y: 0.5)
        fadingView.endPoint = CGPoint(x: 1.0, y: 0.5)
        fadingView.fadeLocations = [0.0, 0.42, 0.58, 1.0]
        return fadingView
    }

}



// Create a UITableViewController for preview
private class PreviewTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Register the cell
        tableView.register(ProChoiceHighlightTableViewCell.self, forCellReuseIdentifier: "ProChoiceHighlightCell")

        // Enable dynamic height
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 // Number of preview cells
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ProChoiceHighlightCell", for: indexPath) as? ProChoiceHighlightTableViewCell else {
            return UITableViewCell()
        }

        // Configure the cell with sample data
        cell.configure(with: ProChoiceHighlightViewModel(
            title: "Sample Title \(indexPath.row + 1)",
            description: "This is a sample description to demonstrate dynamic height in the cell preview. It can span multiple lines based on the content.",
            leagueName: "League Name \(indexPath.row + 1)",
            matchDate: "06.10.2024",
            matchTime: "18:00",
            teamsName: "Team A vs Team B",
            homeOdds: "1.5",
            drawOdds: "3.2",
            awayOdds: "2.8")
        )

        return cell
    }
}

@available(iOS 17, *)
#Preview("ProChoiceHighlightTableViewCell Preview") {
    let vc = PreviewTableViewController()
    return vc
}
