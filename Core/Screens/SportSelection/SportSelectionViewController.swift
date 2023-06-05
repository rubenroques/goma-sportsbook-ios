//
//  SportSelectionViewController.swift
//  ShowcaseProd
//
//  Created by André Lascas on 11/10/2021.
//

import UIKit
import Combine
import ServicesProvider

protocol SportTypeSelectionViewDelegate: AnyObject {
    func selectedSport(_ sport: Sport)
}

class SportSelectionViewController: UIViewController {

    @IBOutlet private var topView: UIView!
    @IBOutlet private var navigationView: UIView!
    @IBOutlet private var navigationLabel: UILabel!
    @IBOutlet private var cancelButton: UIButton!
    @IBOutlet private var collectionView: UICollectionView!
    @IBOutlet private var searchBar: UISearchBar!
    @IBOutlet private var loadingBaseView: UIView!
    @IBOutlet private var activityIndicatorView: UIActivityIndicatorView!

    // Variables
    var sportsData: [Sport] = []
    var fullSportsData: [Sport] = []
    var defaultSport: Sport
    var isLiveSport: Bool

    var allSportsPublisher: AnyCancellable?
    var liveSportsPublisher: AnyCancellable?

    var allSportsSubscribePublisher: AnyCancellable?

    var selectionDelegate: SportTypeSelectionViewDelegate?

    var cancellables = Set<AnyCancellable>()
    private var sportsSubscription: ServicesProvider.Subscription?

    var isLoading: Bool = false {
        didSet {
            if isLoading {
                self.loadingBaseView.isHidden = false
                self.activityIndicatorView.startAnimating()
            }
            else {
                self.loadingBaseView.isHidden = true
                self.activityIndicatorView.stopAnimating()
            }
        }
    }
    
    private var cancellable = Set<AnyCancellable>()

    init(defaultSport: Sport, isLiveSport: Bool = false) {
        self.defaultSport = defaultSport
        self.isLiveSport = isLiveSport
        super.init(nibName: "SportSelectionViewController", bundle: nil)
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        AnalyticsClient.sendEvent(event: .changedSport)
        self.commonInit()
        self.setupWithTheme()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.setupWithTheme()
    }

    deinit {

    }

    func commonInit() {
        
        self.view.bringSubviewToFront(self.loadingBaseView)
        self.isLoading = true

        if isLiveSport {
            //self.getSportsLive()
            self.getAllSports(onlyLiveSports: true)
        }
        else {
            //self.getAvailableSports()
            self.getAllSports()
        }

        self.navigationLabel.text = localized("choose_sport")
        self.navigationLabel.font = AppFont.with(type: .bold, size: 16)

        self.cancelButton.setTitle(localized("cancel"), for: .normal)
        self.cancelButton.titleLabel?.font = AppFont.with(type: .semibold, size: 16)

        self.collectionView.register(SportSelectionCollectionViewCell.nib,
                                       forCellWithReuseIdentifier: SportSelectionCollectionViewCell.identifier)
        self.collectionView.delegate = self
        self.collectionView.dataSource = self

        self.searchBar.delegate = self

    }

    func setupWithTheme() {

        self.view.backgroundColor = UIColor.App.backgroundPrimary
        self.topView.backgroundColor = UIColor.App.backgroundPrimary
        self.navigationView.backgroundColor = UIColor.App.backgroundPrimary
        self.navigationLabel.textColor = UIColor.App.textPrimary
        self.cancelButton.setTitleColor(UIColor.App.highlightPrimary, for: .normal)
        self.collectionView.backgroundColor = UIColor.App.backgroundPrimary

        self.searchBar.searchBarStyle = UISearchBar.Style.prominent
        self.searchBar.sizeToFit()
        self.searchBar.isTranslucent = false
        self.searchBar.backgroundImage = UIImage()
        self.searchBar.backgroundImage = UIColor.App.backgroundPrimary.image()
        self.searchBar.placeholder = localized("search")

        self.searchBar.delegate = self

        if let textfield = searchBar.value(forKey: "searchField") as? UITextField {
            textfield.backgroundColor = UIColor.App.backgroundSecondary
            textfield.textColor = UIColor.App.textPrimary
            textfield.tintColor = UIColor.App.textPrimary
            textfield.attributedPlaceholder = NSAttributedString(string: localized("search_field"),
                                                                 attributes: [NSAttributedString.Key.foregroundColor:
                                                                                
                                                                                               UIColor.App.inputTextTitle])

            if let glassIconView = textfield.leftView as? UIImageView {
                glassIconView.image = glassIconView.image?.withRenderingMode(.alwaysTemplate)
                glassIconView.tintColor =
                UIColor.App.inputTextTitle
            }
        }

        self.loadingBaseView.backgroundColor = UIColor.App.backgroundPrimary

    }

    func getAllSports(onlyLiveSports: Bool = false) {

        self.allSportsSubscribePublisher = Env.servicesProvider.subscribeAllSportTypes()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                print("Env.servicesProvider.allSportTypes completed \(completion)")
            }, receiveValue: { [weak self] (subscribableContent: SubscribableContent<[SportType]>) in
                switch subscribableContent {
                case .connected(subscription: let subscription):
                    self?.sportsSubscription = subscription
                case .contentUpdate(let sportTypes):

                    if onlyLiveSports {
                        let liveSportTypes = sportTypes.filter({
                            $0.numberLiveEvents > 0
                        })
                        self?.configureWithSports(liveSportTypes)
                    }
                    else {
                        let preLiveSports = sportTypes.filter({
                            $0.numberEvents > 0 || $0.numberLiveEvents > 0 || $0.numberOutrightEvents > 0
                        })

                        self?.configureWithSports(preLiveSports)
                    }

                    self?.isLoading = false

                case .disconnected:
                    ()
                }
            })

    }

    func getAvailableSports() {
        self.isLoading = true

        self.allSportsPublisher?.cancel()
        self.allSportsPublisher = nil

        self.allSportsPublisher = Env.servicesProvider.getAvailableSportTypes()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
            }, receiveValue: { [weak self] (sportTypes: [SportType]) in
                self?.configureWithSports(sportTypes)
                self?.isLoading = false
            })

    }

    func getSportsLive() {
        self.isLoading = true

        self.liveSportsPublisher?.cancel()
        self.liveSportsPublisher = nil

        self.liveSportsPublisher = Env.servicesProvider.subscribeLiveSportTypes()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                print("Env.servicesProvider.liveSportTypes completed \(completion)")
                self?.isLoading = false
                self?.configureWithSports([])
            }, receiveValue: { [weak self] (subscribableContent: SubscribableContent<[SportType]>) in
                switch subscribableContent {
                case .connected(subscription: let subscription):
                    self?.sportsSubscription = subscription
                case .contentUpdate(let sportTypes):
                    self?.configureWithSports(sportTypes)
                    self?.isLoading = false
                case .disconnected:
                    self?.configureWithSports([])
                }
            })

    }

    func configureWithSports(_ sportTypes: [ServicesProvider.SportType]) {
        self.sportsData = sportTypes.map({ sportType in
            ServiceProviderModelMapper.sport(fromServiceProviderSportType: sportType)
        })
        self.fullSportsData = self.sportsData
        self.collectionView.reloadData()
    }

    @IBAction private func cancelAction() {
        self.dismiss(animated: true, completion: nil)
    }

}

extension SportSelectionViewController: UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let cell = collectionView.dequeueCellType(SportSelectionCollectionViewCell.self, indexPath: indexPath),
            let sport = sportsData[safe: indexPath.row]
        else {
            fatalError()
        }

        // TODO: Refactor this logic to the CellViewModel
        let viewModel = SportSelectionCollectionViewCellViewModel(sport: sport, isLive: isLiveSport)

        cell.configureCell(viewModel: viewModel)

        if cell.viewModel?.sportId == self.defaultSport.id {
            cell.isSelected = true
            collectionView.selectItem(at: indexPath, animated: false, scrollPosition: UICollectionView.ScrollPosition.centeredHorizontally)
        }
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.sportsData.count
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        guard
            let sportAtIndex = sportsData[safe: indexPath.row],
            let cell = collectionView.cellForItem(at: indexPath) as? SportSelectionCollectionViewCell
        else {
            collectionView.deselectItem(at: indexPath, animated: true)
            return
        }

        cell.isSelected = true
        self.defaultSport = sportAtIndex

        self.selectionDelegate?.selectedSport(sportAtIndex)

        AnalyticsClient.sendEvent(event: .selectedSport(sportId: self.defaultSport.id))
        self.dismiss(animated: true, completion: nil)
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        self.sportsData.removeAll()

        if !searchText.isEmpty {
            for sport in self.fullSportsData {
                if sport.name.lowercased().contains(searchText.lowercased()) {
                    self.sportsData.append(sport)
                }
            }
        }
        else {
            self.sportsData = self.fullSportsData
        }
        self.collectionView.reloadData()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.resignFirstResponder()
    }

}
