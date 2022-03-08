//
//  LiveEventsViewController.swift
//  Sportsbook
//
//  Created by Ruben Roques on 28/09/2021.
//

import UIKit
import Combine
import OrderedCollections
import SwiftUI

class LiveEventsViewController: UIViewController {

    @IBOutlet private weak var filtersBarBaseView: UIView!
    @IBOutlet private weak var filtersCollectionView: UICollectionView!
    @IBOutlet private weak var filtersSeparatorLineView: UIView!
    @IBOutlet private weak var tableView: UITableView!

    @IBOutlet private weak var sportTypeIconImageView: UIImageView!
    @IBOutlet private weak var leftGradientBaseView: UIView!
    @IBOutlet private weak var sportsSelectorButtonView: UIView!

    @IBOutlet private weak var rightGradientBaseView: UIView!
    @IBOutlet private weak var filtersButtonView: UIView!

    @IBOutlet private weak var filtersCountLabel: UILabel!
    
    @IBOutlet private weak var emptyBaseView: UIView!
    @IBOutlet private weak var firstTextFieldEmptyStateLabel: UILabel!
    @IBOutlet private weak var secondTextFieldEmptyStateLabel: UILabel!
    @IBOutlet private weak var emptyStateImage: UIImageView!
    @IBOutlet private weak var emptyStateButton: UIButton!
    
    @IBOutlet private weak var liveEventsCountView: UIView!
    @IBOutlet private weak var liveEventsCountLabel: UILabel!

    var turnTimeRangeOn: Bool = false
    
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

    @IBOutlet private weak var loadingBaseView: UIView!
    @IBOutlet private weak var loadingView: UIActivityIndicatorView!

    var cancellables = Set<AnyCancellable>()

    var viewModel: LiveEventsViewModel

    var filterSelectedOption: Int = 0
    var selectedSport: Sport {
        didSet {
            self.sportTypeIconImageView.image = UIImage(named: "sport_type_mono_icon_\(selectedSport.id)")
            self.viewModel.selectedSport = selectedSport
        }
    }

    var didChangeSport: ((Sport) -> Void)?
    var didTapBetslipButtonAction: (() -> Void)?

    init(selectedSport: Sport = Sport.football) {
        self.selectedSport = selectedSport
        self.viewModel = LiveEventsViewModel(selectedSport: self.selectedSport)
        super.init(nibName: "LiveEventsViewController", bundle: nil)
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.bringSubviewToFront(self.loadingBaseView)

        self.commonInit()
        self.setupWithTheme()
        self.connectPublishers()
        self.viewModel.fetchData()

        self.viewModel.didSelectMatchAction = { match, image in
            let matchDetailsViewController = MatchDetailsViewController(matchMode: .live, match: match)
            matchDetailsViewController.viewModel.gameSnapshot = image
            self.navigationController?.pushViewController(matchDetailsViewController, animated: true)
        }

        self.viewModel.updateNumberOfLiveEventsAction = {
            if self.viewModel.selectedSportNumberofLiveEvents != 0 {

                self.liveEventsCountView.isHidden = false
                self.liveEventsCountLabel.text = "\(self.viewModel.selectedSportNumberofLiveEvents)"
            }
            else {
                self.liveEventsCountView.isHidden = true
            }
        }
        
        self.tableView.isHidden = false
        self.emptyBaseView.isHidden = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.tableView.reloadData()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        self.filtersButtonView.layer.cornerRadius = self.filtersButtonView.frame.height / 2
        self.sportsSelectorButtonView.layer.cornerRadius = self.sportsSelectorButtonView.frame.height / 2
        self.betslipButtonView.layer.cornerRadius = self.betslipButtonView.frame.height / 2
        self.betslipCountLabel.layer.cornerRadius = self.betslipCountLabel.frame.height / 2
    }

    private func commonInit() {

        self.sportTypeIconImageView.image = UIImage(named: "sport_type_mono_icon_1")
       
        let color = UIColor.App.backgroundPrimary

        self.leftGradientBaseView.backgroundColor = color
        let leftGradientMaskLayer = CAGradientLayer()
        leftGradientMaskLayer.frame = self.leftGradientBaseView.bounds
        leftGradientMaskLayer.colors = [UIColor.white.cgColor, UIColor.white.cgColor, UIColor.clear.cgColor]
        leftGradientMaskLayer.locations = [0, 0.55, 1]
        leftGradientMaskLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        leftGradientMaskLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        self.leftGradientBaseView.layer.mask = leftGradientMaskLayer

        //
        self.rightGradientBaseView.backgroundColor = color
        let rightGradientMaskLayer = CAGradientLayer()
        rightGradientMaskLayer.frame = self.rightGradientBaseView.bounds
        rightGradientMaskLayer.colors = [UIColor.clear.cgColor, UIColor.white.cgColor, UIColor.white.cgColor]
        rightGradientMaskLayer.locations = [0, 0.45, 1]
        rightGradientMaskLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        rightGradientMaskLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        self.rightGradientBaseView.layer.mask = rightGradientMaskLayer
        
      
        let tapFilterGesture = UITapGestureRecognizer(target: self, action: #selector(self.didTapFilterAction))
        filtersButtonView.addGestureRecognizer(tapFilterGesture)
        filtersButtonView.isUserInteractionEnabled = true
        filtersButtonView.backgroundColor = UIColor.App.backgroundTertiary

        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        flowLayout.scrollDirection = .horizontal
        filtersCollectionView.collectionViewLayout = flowLayout
        filtersCollectionView.contentInset = UIEdgeInsets(top: 0, left: 74, bottom: 0, right: 54)
        filtersCollectionView.showsVerticalScrollIndicator = false
        filtersCollectionView.showsHorizontalScrollIndicator = false
        filtersCollectionView.alwaysBounceHorizontal = true
        filtersCollectionView.register(ListTypeCollectionViewCell.nib,
                                       forCellWithReuseIdentifier: ListTypeCollectionViewCell.identifier)
        filtersCollectionView.delegate = self
        filtersCollectionView.dataSource = self
        
        filtersCountLabel.isHidden = true
        liveEventsCountView.isHidden = true
       

        tableView.separatorStyle = .none
        tableView.register(MatchLineTableViewCell.nib, forCellReuseIdentifier: MatchLineTableViewCell.identifier)
        tableView.register(BannerScrollTableViewCell.nib, forCellReuseIdentifier: BannerScrollTableViewCell.identifier)
        tableView.register(LoadingMoreTableViewCell.nib, forCellReuseIdentifier: LoadingMoreTableViewCell.identifier)
        tableView.register(TitleTableViewHeader.nib, forHeaderFooterViewReuseIdentifier: TitleTableViewHeader.identifier)
        tableView.register(TournamentTableViewHeader.nib, forHeaderFooterViewReuseIdentifier: TournamentTableViewHeader.identifier)

        tableView.delegate = self
        tableView.dataSource = self

        tableView.estimatedRowHeight = 155
        tableView.estimatedSectionHeaderHeight = 0
        tableView.estimatedSectionFooterHeight = 0

        let didTapSportsSelection = UITapGestureRecognizer(target: self, action: #selector(handleSportsSelectionTap))
        sportsSelectorButtonView.addGestureRecognizer(didTapSportsSelection)
        
        self.betslipButtonView.addSubview(self.betslipCountLabel)

        self.view.addSubview(self.betslipButtonView)
        self.betslipCountLabel.isHidden = true

        NSLayoutConstraint.activate([
            self.betslipCountLabel.trailingAnchor.constraint(equalTo: self.betslipButtonView.trailingAnchor, constant: 2),
            self.betslipCountLabel.topAnchor.constraint(equalTo: self.betslipButtonView.topAnchor, constant: -3),

            self.betslipButtonView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -12),
            self.betslipButtonView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -12)
        ])

        self.view.bringSubviewToFront(self.loadingBaseView)

        let tapBetslipView = UITapGestureRecognizer(target: self, action: #selector(didTapBetslipView))
        betslipButtonView.addGestureRecognizer(tapBetslipView)

        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()

        // TODO: Code Review - Este HomeFilterViewController com o nome (errado) homeFilterVC não está a ser
        // utilizado em lado nenhum e é desalocado logo a seguir
        let homeFilterVC = HomeFilterViewController(liveEventsViewModel: self.viewModel)
        homeFilterVC.delegate = self
    }

    func connectPublishers() {

        self.viewModel.isLoading
            .receive(on: DispatchQueue.main)
            .sink { isLoading in
                self.loadingBaseView.isHidden = !isLoading
            }
            .store(in: &cancellables)

        self.viewModel.dataDidChangedAction = { [unowned self] in
            self.tableView.reloadData()
        }

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
        
        self.viewModel.screenStatePublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] screenState in
              
            
                switch screenState {
                case .noEmptyNoFilter:
                    self?.emptyBaseView.isHidden = true
                    self?.tableView.isHidden = false
          
                case .emptyNoFilter:
                    self?.setEmptyStateBaseView(firstLabelText: localized("empty_list"), secondLabelText: localized("second_empty_list"), isUserLoggedIn: true)
                    self?.emptyBaseView.isHidden = false
                    self?.tableView.isHidden = true
                    
                case .noEmptyAndFilter:
                    self?.emptyBaseView.isHidden = true
                    self?.tableView.isHidden = false
                case .emptyAndFilter:
                    self?.setEmptyStateBaseView(firstLabelText: localized("empty_list_with_filters"), secondLabelText: localized("second_empty_list_with_filters"), isUserLoggedIn: true)
                    self?.emptyBaseView.isHidden = false
                    self?.tableView.isHidden = true
            
                }
            })
            .store(in: &cancellables)

    }

    private func setupWithTheme() {
        
   
        
        self.leftGradientBaseView.backgroundColor = UIColor.App.backgroundSecondary
        self.rightGradientBaseView.backgroundColor = UIColor.App.backgroundSecondary
        
        self.filtersBarBaseView.backgroundColor = UIColor.App.backgroundPrimary
        filtersCollectionView.backgroundColor = UIColor.App.backgroundSecondary

        self.sportsSelectorButtonView.backgroundColor = UIColor.App.buttonBackgroundPrimary
        self.sportsSelectorButtonView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]

        self.filtersButtonView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        
        self.liveEventsCountView.layer.cornerRadius = self.liveEventsCountView.frame.size.width/2
        self.liveEventsCountView.backgroundColor = UIColor.App.highlightSecondary
        self.filtersCountLabel.font = AppFont.with(type: .bold, size: 10.0)
        self.filtersCountLabel.backgroundColor = UIColor.App.highlightSecondary

        self.liveEventsCountLabel.font = AppFont.with(type: .semibold, size: 9)
        
        self.tableView.backgroundColor = .clear
        self.tableView.backgroundView?.backgroundColor = .clear
        
        self.view.backgroundColor = UIColor.App.backgroundPrimary

        self.filtersBarBaseView.backgroundColor = UIColor.App.backgroundSecondary
        self.filtersSeparatorLineView.backgroundColor = UIColor.App.separatorLine

        self.tableView.backgroundColor = UIColor.App.backgroundPrimary
        self.tableView.backgroundView?.backgroundColor = UIColor.App.backgroundPrimary
        
        self.filtersCollectionView.backgroundColor = UIColor.App.backgroundSecondary

        self.betslipCountLabel.backgroundColor = UIColor.App.alertError
        self.betslipButtonView.backgroundColor = UIColor.App.buttonBackgroundPrimary
    
        self.emptyBaseView.backgroundColor = UIColor.App.backgroundPrimary
        self.firstTextFieldEmptyStateLabel.textColor = UIColor.App.textPrimary
        self.secondTextFieldEmptyStateLabel.textColor = UIColor.App.textPrimary
        self.emptyStateButton.backgroundColor = UIColor.App.buttonBackgroundPrimary

        self.betslipCountLabel.textColor = UIColor.App.buttonTextPrimary
        self.liveEventsCountLabel.textColor = UIColor.App.buttonTextPrimary
    }

    @objc func didTapFilterAction(sender: UITapGestureRecognizer) {
        let homeFilterViewController = HomeFilterViewController(liveEventsViewModel: self.viewModel)
        homeFilterViewController.delegate = self
        self.present(homeFilterViewController, animated: true, completion: nil)
        
    }
    
    func reloadData() {
        self.tableView.reloadData()
    }

    func changedSport(_ sport: Sport) {
        self.selectedSport = sport
        self.didChangeSport?(sport)
    }

    @objc func handleSportsSelectionTap() {
        let sportSelectionViewController = SportSelectionViewController(defaultSport: self.selectedSport,
                                                            isLiveSport: true,
                                                            sportsRepository: self.viewModel.sportsRepository)
        sportSelectionViewController.selectionDelegate = self
        self.present(sportSelectionViewController, animated: true, completion: nil)
    }

    @objc func didTapBetslipView() {
        self.didTapBetslipButtonAction?()
    }
    
    func setEmptyStateBaseView(firstLabelText : String, secondLabelText : String, isUserLoggedIn : Bool){
    
        if isUserLoggedIn {
            self.emptyStateImage.image = UIImage(named: "no_content_icon")
            self.firstTextFieldEmptyStateLabel.text = firstLabelText
            self.secondTextFieldEmptyStateLabel.text = secondLabelText
            self.emptyStateButton.isHidden = isUserLoggedIn
        }else{
            self.emptyStateImage.image = UIImage(named: "no_internet_icon")
            self.firstTextFieldEmptyStateLabel.text = localized("empty_no_login")
            self.secondTextFieldEmptyStateLabel.text = localized("second_empty_no_login")
            self.emptyStateButton.isHidden = isUserLoggedIn
            self.emptyStateButton.setTitle(localized("login"), for: .normal)
        }
        
    }


}

extension LiveEventsViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.viewModel.numberOfSections(in: tableView)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.tableView(tableView, numberOfRowsInSection: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return self.viewModel.tableView(tableView, cellForRowAt: indexPath)
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        return self.viewModel.tableView(tableView, willDisplay: cell, forRowAt: indexPath)
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return self.viewModel.tableView(tableView, viewForHeaderInSection: section)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.viewModel.tableView(tableView, heightForRowAt: indexPath)
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.viewModel.tableView(tableView, estimatedHeightForRowAt: indexPath)
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.viewModel.tableView(tableView, heightForHeaderInSection: section)
    }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return self.viewModel.tableView(tableView, estimatedHeightForHeaderInSection: section)
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }

    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }

}

extension LiveEventsViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let cell = collectionView.dequeueCellType(ListTypeCollectionViewCell.self, indexPath: indexPath)
        else {
            fatalError()
        }

        switch indexPath.row {
        case 0:
            cell.setupWithTitle(localized("all"))
        default:
            ()
        }

        if filterSelectedOption == indexPath.row {
            cell.setSelectedType(true)
        }
        else {
            cell.setSelectedType(false)
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        self.filterSelectedOption = indexPath.row

        switch indexPath.row {
        case 0:
            self.viewModel.setMatchListType(.allMatches)
        default:
            ()
        }

        self.filtersCollectionView.reloadData()
        self.filtersCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }

}

extension LiveEventsViewController: HomeFilterOptionsViewDelegate {

    func setHomeFilters(homeFilters: HomeFilterOptions) {
        self.viewModel.homeFilterOptions = homeFilters
        
        if homeFilters.countFilters != 0 {
            filtersCountLabel.isHidden = false
            self.view.bringSubviewToFront(filtersCountLabel)
            filtersCountLabel.text = String(homeFilters.countFilters)
            filtersCountLabel.layer.cornerRadius =  filtersCountLabel.frame.width/2
            filtersCountLabel.layer.masksToBounds = true
        }
        else {
            filtersCountLabel.isHidden = true
        }
    }
    
}

extension LiveEventsViewController: SportTypeSelectionViewDelegate {

    func selectedSport(_ sport: Sport) {
        self.changedSport(sport)
    }

}
