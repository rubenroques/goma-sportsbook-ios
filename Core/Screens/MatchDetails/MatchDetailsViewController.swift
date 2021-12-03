//
//  MatchDetailsViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 23/11/2021.
//

import UIKit
import Combine

class MatchDetailsViewController: UIViewController {

    @IBOutlet private var topView: UIView!
    @IBOutlet private var headerDetailView: UIView!
    @IBOutlet private var headerDetailTopView: UIView!
    @IBOutlet private var backButton: UIButton!
    @IBOutlet private var headerCompetitionDetailView: UIView!
    @IBOutlet private var headerCompetitionLabel: UILabel!
    @IBOutlet private var headerCompetitionImageView: UIImageView!

    @IBOutlet private var headerDetailStackView: UIStackView!
    @IBOutlet private var headerDetailHomeView: UIView!
    @IBOutlet private var headerDetailHomeLabel: UILabel!
    @IBOutlet private var headerDetailAwayView: UIView!
    @IBOutlet private var headerDetailAwayLabel: UILabel!

    @IBOutlet private var headerDetailMiddleView: UIView!
    @IBOutlet private var headerDetailMiddleStackView: UIStackView!

    @IBOutlet private var headerDetailPreliveView: UIView!
    @IBOutlet private var headerDetailPreliveTopLabel: UILabel!
    @IBOutlet private var headerDetailPreliveBottomLabel: UILabel!

    @IBOutlet private var headerDetailLiveView: UIView!
    @IBOutlet private var headerDetailLiveTopLabel: UILabel!
    @IBOutlet private var headerDetailLiveBottomLabel: UILabel!

    @IBOutlet private var marketTypesCollectionView: UICollectionView!
    @IBOutlet private var tableView: UITableView!

    @IBOutlet private var loadingView: UIActivityIndicatorView!

    private lazy var betslipButtonView: UIView = {
        var betslipButtonView = UIView()
        betslipButtonView.translatesAutoresizingMaskIntoConstraints = false

        var iconImageView = UIImageView()
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.image = UIImage(named: "betslip_button_icon")
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        betslipButtonView.addSubview(iconImageView)

        NSLayoutConstraint.activate([
            betslipButtonView.widthAnchor.constraint(equalToConstant: 56),
            betslipButtonView.widthAnchor.constraint(equalTo: betslipButtonView.heightAnchor),

            iconImageView.widthAnchor.constraint(equalToConstant: 30),
            iconImageView.widthAnchor.constraint(equalTo: iconImageView.heightAnchor),

            iconImageView.centerXAnchor.constraint(equalTo: betslipButtonView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: betslipButtonView.centerYAnchor),
        ])

        return betslipButtonView
    }()
    private lazy var betslipCountLabel: UILabel = {
        var betslipCountLabel = UILabel()
        betslipCountLabel.translatesAutoresizingMaskIntoConstraints = false
        betslipCountLabel.textColor = .white
        betslipCountLabel.backgroundColor = UIColor.App.alertError
        betslipCountLabel.font = AppFont.with(type: .semibold, size: 10)
        betslipCountLabel.textAlignment = .center
        betslipCountLabel.clipsToBounds = true
        betslipCountLabel.layer.masksToBounds = true
        betslipCountLabel.text = "0"
        NSLayoutConstraint.activate([
            betslipCountLabel.widthAnchor.constraint(equalToConstant: 20),
            betslipCountLabel.widthAnchor.constraint(equalTo: betslipCountLabel.heightAnchor),
        ])
        return betslipCountLabel
    }()
    
    enum MatchMode {
        case preLive
        case live
    }

    var matchMode: MatchMode {
        didSet {
            if matchMode == .preLive {
                self.headerDetailLiveView.isHidden = true

                self.headerDetailPreliveView.isHidden = false

            }
            else {
                self.headerDetailPreliveView.isHidden = true

                self.headerDetailLiveView.isHidden = false

            }

            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
        }
    }

    var match: Match

    var viewModel: MatchDetailsViewModel

    var matchDetails: [Match] = []

    private var matchDetailsRegister: EndpointPublisherIdentifiable?
    var matchDetailsAggregatorPublisher: AnyCancellable?

    private var cancellables = Set<AnyCancellable>()

    init(matchMode: MatchMode = .preLive, match: Match) {
        self.matchMode = matchMode
        self.match = match
        self.viewModel = MatchDetailsViewModel(match: match)

        super.init(nibName: "MatchDetailsViewController", bundle: nil)
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.commonInit()
        self.setupWithTheme()

        self.viewModel.marketGroupsTypesDataChanged = { [weak self] in
            self?.marketTypesCollectionView.reloadData()
        }

        self.viewModel.marketGroupDataChanged = {[weak self] in
            self?.tableView.reloadData()
        }

        self.viewModel.isLoadingData
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                if isLoading {
                    self?.loadingView.startAnimating()
                }
                else {
                    self?.loadingView.stopAnimating()
                }
            }
            .store(in: &cancellables)


        Env.betslipManager.bettingTicketsPublisher
            .map(\.count)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] betslipValue in

                if betslipValue == 0 {
                    self?.betslipCountLabel.isHidden = true
                }
                else {
                    self?.betslipCountLabel.text = "\(betslipValue)"
                    self?.betslipCountLabel.isHidden = false
                }
            })
            .store(in: &cancellables)
        
        self.marketTypesCollectionView.reloadData()
        self.tableView.reloadData()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    deinit {
        if let matchDetailsRegister = matchDetailsRegister {
            TSManager.shared.unregisterFromEndpoint(endpointPublisherIdentifiable: matchDetailsRegister)
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.betslipButtonView.layer.cornerRadius = self.betslipButtonView.frame.height / 2
        self.betslipCountLabel.layer.cornerRadius = self.betslipCountLabel.frame.height / 2
    }

    func commonInit() {

        self.loadingView.hidesWhenStopped = true
        self.loadingView.stopAnimating()

        self.backButton.setImage(UIImage(named: "arrow_back_icon"), for: .normal)

        self.headerCompetitionLabel.text = "Primeira Liga"
        self.headerCompetitionLabel.font = AppFont.with(type: .semibold, size: 11)

        self.headerCompetitionImageView.image = UIImage(named: "country_flag_pt")
        self.headerCompetitionImageView.layer.cornerRadius = self.headerCompetitionImageView.frame.width/2
        self.headerCompetitionImageView.contentMode = .center

        self.headerDetailHomeLabel.text = "Home Team"
        self.headerDetailHomeLabel.font = AppFont.with(type: .bold, size: 16)
        self.headerDetailHomeLabel.numberOfLines = 0

        self.headerDetailAwayLabel.text = "Away Team"
        self.headerDetailAwayLabel.font = AppFont.with(type: .bold, size: 16)
        self.headerDetailAwayLabel.numberOfLines = 0

        self.headerDetailPreliveTopLabel.text = "Match Day"
        self.headerDetailPreliveTopLabel.font = AppFont.with(type: .semibold, size: 12)

        self.headerDetailPreliveBottomLabel.text = "12:00"
        self.headerDetailPreliveBottomLabel.font = AppFont.with(type: .bold, size: 16)

        self.headerDetailLiveTopLabel.text = "0 - 0"
        self.headerDetailLiveTopLabel.font = AppFont.with(type: .bold, size: 16)

        self.headerDetailLiveBottomLabel.text = "Match Start"
        self.headerDetailLiveBottomLabel.font = AppFont.with(type: .semibold, size: 12)
        self.headerDetailLiveBottomLabel.numberOfLines = 0

        if self.matchMode == .preLive {
            self.headerDetailLiveView.isHidden = true
            self.headerDetailPreliveView.isHidden = false
        }
        else {
            self.headerDetailPreliveView.isHidden = true
            self.headerDetailLiveView.isHidden = false
        }

        setupMatchDetailPublisher()

        setupHeaderDetails()

        // Market Types CollectionView
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        flowLayout.scrollDirection = .horizontal
        self.marketTypesCollectionView.collectionViewLayout = flowLayout
        self.marketTypesCollectionView.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        self.marketTypesCollectionView.showsVerticalScrollIndicator = false
        self.marketTypesCollectionView.showsHorizontalScrollIndicator = false
        self.marketTypesCollectionView.register(ListTypeCollectionViewCell.nib,
                                       forCellWithReuseIdentifier: ListTypeCollectionViewCell.identifier)
        self.marketTypesCollectionView.delegate = self.viewModel
        self.marketTypesCollectionView.dataSource = self.viewModel

        // TableView
        self.tableView.backgroundColor = .clear
        self.tableView.backgroundView?.backgroundColor = .clear

        self.tableView.separatorStyle = .none
        self.tableView.register(SimpleListMarketDetailTableViewCell.nib, forCellReuseIdentifier: SimpleListMarketDetailTableViewCell.identifier)
        self.tableView.register(ThreeAwayMarketDetailTableViewCell.nib, forCellReuseIdentifier: ThreeAwayMarketDetailTableViewCell.identifier)
        self.tableView.register(OverUnderMarketDetailTableViewCell.nib, forCellReuseIdentifier: OverUnderMarketDetailTableViewCell.identifier)

        self.tableView.delegate = self.viewModel
        self.tableView.dataSource = self.viewModel

        self.betslipButtonView.addSubview(self.betslipCountLabel)

        self.view.addSubview(self.betslipButtonView)
        self.betslipCountLabel.isHidden = true

        NSLayoutConstraint.activate([
            self.betslipCountLabel.trailingAnchor.constraint(equalTo: self.betslipButtonView.trailingAnchor, constant: 2),
            self.betslipCountLabel.topAnchor.constraint(equalTo: self.betslipButtonView.topAnchor, constant: -3),

            self.betslipButtonView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -12),
            self.betslipButtonView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -12)
        ])

        let tapBetslipView = UITapGestureRecognizer(target: self, action: #selector(didTapBetslipView))
        betslipButtonView.addGestureRecognizer(tapBetslipView)

        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()

    }

    func setupWithTheme() {

        self.view.backgroundColor = UIColor.App.mainBackground

        self.topView.backgroundColor = UIColor.App.secondaryBackground
        self.headerDetailView.backgroundColor = UIColor.App.secondaryBackground

        self.headerDetailTopView.backgroundColor = UIColor.App.secondaryBackground

        self.backButton.tintColor = UIColor.App.headingMain

        self.headerCompetitionDetailView.backgroundColor = UIColor.App.secondaryBackground

        self.headerCompetitionLabel.textColor = UIColor.App.headingDisabled

        self.headerDetailStackView.backgroundColor = UIColor.App.secondaryBackground

        self.headerDetailHomeView.backgroundColor = UIColor.App.secondaryBackground
        self.headerDetailHomeLabel.textColor = UIColor.App.headingMain

        self.headerDetailAwayView.backgroundColor = UIColor.App.secondaryBackground
        self.headerDetailAwayLabel.textColor = UIColor.App.headingMain

        self.headerDetailMiddleView.backgroundColor = UIColor.App.secondaryBackground

        self.headerDetailMiddleStackView.backgroundColor = UIColor.App.secondaryBackground

        self.headerDetailPreliveView.backgroundColor = UIColor.App.secondaryBackground
        self.headerDetailPreliveTopLabel.textColor = UIColor.App.headingMain.withAlphaComponent(0.5)
        self.headerDetailPreliveBottomLabel.textColor = UIColor.App.headingMain

        self.headerDetailLiveView.backgroundColor = UIColor.App.secondaryBackground
        self.headerDetailLiveTopLabel.textColor = UIColor.App.headingMain
        self.headerDetailLiveBottomLabel.textColor = UIColor.App.headingMain.withAlphaComponent(0.5)

        // Market List CollectionView
        self.marketTypesCollectionView.backgroundColor = .clear

        // TableView
        self.tableView.backgroundColor = .clear

        self.betslipCountLabel.backgroundColor = UIColor.App.alertError
        self.betslipButtonView.backgroundColor = UIColor.App.mainTint
    }

    func setupMatchDetailPublisher() {
        if let matchDetailsRegister = matchDetailsRegister {
            TSManager.shared.unregisterFromEndpoint(endpointPublisherIdentifiable: matchDetailsRegister)
        }


        let endpoint = TSRouter.matchDetailsAggregatorPublisher(operatorId: Env.appSession.operatorId,
                                                                language: "en", matchId: match.id)
        print("ENDPOINT: \(endpoint)")
        self.matchDetailsAggregatorPublisher?.cancel()
        self.matchDetailsAggregatorPublisher = nil

        self.matchDetailsAggregatorPublisher = TSManager.shared
            .registerOnEndpoint(endpoint, decodingType: EveryMatrix.Aggregator.self)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure:
                    print("Error retrieving data!")
                case .finished:
                    print("Data retrieved!")
                }
            }, receiveValue: { [weak self] state in
                switch state {
                case .connect(let publisherIdentifiable):
                    print("MatchDetailsAggregator matchDetailsAggregatorPublisher connect")
                    self?.matchDetailsRegister = publisherIdentifiable
                case .initialContent(let aggregator):
                    print("MatchDetailsAggregator matchDetailsAggregatorPublisher initialContent")
                    self?.setupMatchDetailAggregatorProcessor(aggregator: aggregator)
                    print("MATCH DETAIL AGG: \(aggregator)")
                case .updatedContent(let aggregatorUpdates):
                    print("MatchDetailsAggregator matchDetailsAggregatorPublisher updatedContent")
                    self?.updateMatchDetailAggregatorProcessor(aggregator: aggregatorUpdates)
                case .disconnect:
                    print("MatchDetailsAggregator matchDetailsAggregatorPublisher disconnect")
                }
            })
    }

    private func setupMatchDetailAggregatorProcessor(aggregator: EveryMatrix.Aggregator) {
        Env.everyMatrixStorage.processAggregator(aggregator, withListType: .matchDetails,
                                                 shouldClear: true)
    }

    private func updateMatchDetailAggregatorProcessor(aggregator: EveryMatrix.Aggregator) {
        print("UPDATE MATCH DETAIL: \(aggregator)")
        Env.everyMatrixStorage.processContentUpdateAggregator(aggregator)

        DispatchQueue.main.async {
            if !Env.everyMatrixStorage.matchesInfoForMatch.isEmpty && self.matchMode == .preLive {
                self.matchMode = .live
            }
            self.updateHeaderDetails()
        }


    }

    func setupHeaderDetails() {
        let viewModel = MatchWidgetCellViewModel(match: self.match)

        self.headerCompetitionImageView.image = UIImage(named: Assets.flagName(withCountryCode: viewModel.countryISOCode))
        self.headerCompetitionLabel.text = viewModel.competitionName
        self.headerDetailHomeLabel.text = viewModel.homeTeamName
        self.headerDetailAwayLabel.text = viewModel.awayTeamName

        if matchMode == .preLive {
            self.headerDetailPreliveTopLabel.text = viewModel.startDateString
            self.headerDetailPreliveBottomLabel.text = viewModel.startTimeString
        }
        else {
            updateHeaderDetails()
        }
    }

    func updateHeaderDetails() {
        var homeGoals = ""
        var awayGoals = ""
        var minutes = ""
        var matchPart = ""

        if let matchInfoArray = Env.everyMatrixStorage.matchesInfoForMatch[match.id] {
            for matchInfoId in matchInfoArray {
                if let matchInfo = Env.everyMatrixStorage.matchesInfo[matchInfoId] {
                    if (matchInfo.typeId ?? "") == "1" {
                        // Goals
                        if let homeGoalsFloat = matchInfo.paramFloat1 {
                            if self.match.homeParticipant.id == matchInfo.paramParticipantId1 {
                                homeGoals = "\(homeGoalsFloat)"
                            }
                            else if self.match.awayParticipant.id == matchInfo.paramParticipantId1 {
                                awayGoals = "\(homeGoalsFloat)"
                            }
                        }
                        if let awayGoalsFloat = matchInfo.paramFloat2 {
                            if self.match.homeParticipant.id == matchInfo.paramParticipantId2 {
                                homeGoals = "\(awayGoalsFloat)"
                            }
                            else if self.match.awayParticipant.id == matchInfo.paramParticipantId2 {
                                awayGoals = "\(awayGoalsFloat)"
                            }
                        }
                    }
                    else if (matchInfo.typeId ?? "") == "95", let minutesFloat = matchInfo.paramFloat1 {
                        // Match Minutes
                        minutes = "\(minutesFloat)"
                    }
                    else if (matchInfo.typeId ?? "") == "92", let eventPartName = matchInfo.paramEventPartName1 {
                        // Status Part
                        matchPart = eventPartName
                    }
                }
            }
        }

        if homeGoals.isNotEmpty && awayGoals.isNotEmpty {
            self.headerDetailLiveTopLabel.text = "\(homeGoals) - \(awayGoals)"
        }

        if minutes.isNotEmpty && matchPart.isNotEmpty {
            self.headerDetailLiveBottomLabel.text = "\(minutes)' - \(matchPart)"
        }
        else if minutes.isNotEmpty {
            self.headerDetailLiveBottomLabel.text = "\(minutes)'"
        }
        else if matchPart.isNotEmpty {
            self.headerDetailLiveBottomLabel.text = "\(matchPart)"
        }
    }

    @objc func didTapBetslipView() {
        self.openBetslipModal()
    }

    func openBetslipModal() {

        let betslipViewController = BetslipViewController()
        betslipViewController.willDismissAction = { [weak self] in
            self?.marketTypesCollectionView.reloadData()
            self?.tableView.reloadData()
        }

        self.present(Router.navigationController(with: betslipViewController), animated: true, completion: {

        })

    }
    
    @IBAction func didTapBackAction() {
        self.navigationController?.popViewController(animated: true)
    }

}
