//
//  SportSelectionViewController.swift
//  ShowcaseProd
//
//  Created by André Lascas on 11/10/2021.
//

import UIKit
import Combine
import ServiceProvider

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
    var sportsRepository: SportsAggregatorRepository

    var allSportsPublisher: AnyCancellable?
    var allSportsRegister: EndpointPublisherIdentifiable?

    var liveSportsPublisher: AnyCancellable?
    var liveSportsRegister: EndpointPublisherIdentifiable?

    var liveSportsDetailsCancellable: AnyCancellable?
    
    var selectionDelegate: SportTypeSelectionViewDelegate?

    var cancellables = Set<AnyCancellable>()

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

    init(defaultSport: Sport, isLiveSport: Bool = false, sportsRepository: SportsAggregatorRepository = SportsAggregatorRepository()) {
        self.defaultSport = defaultSport
        self.isLiveSport = isLiveSport
        self.sportsRepository = sportsRepository
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
        print("SPORT SELECTION DEINIT")
        Env.serviceProvider.unsubscribeAllSportTypes()
    }

    func commonInit() {
        
        self.view.bringSubviewToFront(self.loadingBaseView)
        self.isLoading = true

        if isLiveSport {
            getSportsLive()
        }
        else {
            getSports()
        }

        navigationLabel.text = localized("choose_sport")
        navigationLabel.font = AppFont.with(type: .bold, size: 16)

        cancelButton.setTitle(localized("cancel"), for: .normal)
        cancelButton.titleLabel?.font = AppFont.with(type: .semibold, size: 16)

        collectionView.register(SportSelectionCollectionViewCell.nib,
                                       forCellWithReuseIdentifier: SportSelectionCollectionViewCell.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self

        searchBar.delegate = self

    }

    func setupWithTheme() {

        self.view.backgroundColor = UIColor.App.backgroundPrimary
        topView.backgroundColor = UIColor.App.backgroundPrimary
        navigationView.backgroundColor = UIColor.App.backgroundPrimary
        navigationLabel.textColor = UIColor.App.textPrimary
        cancelButton.setTitleColor(UIColor.App.highlightPrimary, for: .normal)
        collectionView.backgroundColor = UIColor.App.backgroundPrimary

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

    func getSports() {

//        let sports = Env.everyMatrixClient.getDisciplines(language: "en")
//
//        sports
//            .receive(on: DispatchQueue.main)
//            .sink(receiveCompletion: { completion in
//                switch completion {
//                case .failure:
//                    print("Error retrieving data!")
//                case .finished:
//                    print("Data retrieved!")
//                }
//                self.activityIndicatorView.isHidden = true
//            }, receiveValue: { value in
//                self.sportsData = value.records ?? []
//                self.fullSportsData = self.sportsData
//                self.collectionView.reloadData()
//            })
//            .store(in: &self.cancellable)

        self.isLoading = true

        Env.serviceProvider.getAllSportsList()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {

                case .finished:
                    print("UNIFIED SPORTS LIST FINISHED")
                case .failure(let error):
                    print("UNIFIED SPORTS LIST ERROR: \(error)")
                    self?.isLoading = false
                }

            }, receiveValue: { [weak self] sportsList in
                self?.configureWithAllSports(sportsList)

            })
            .store(in: &cancellables)

    }

    func getSportsLive() {
        
        self.liveSportsPublisher?.cancel()
        self.liveSportsPublisher = nil

        self.liveSportsPublisher = Env.serviceProvider.liveSportTypes()?
            .sink(receiveCompletion: { [weak self] completion in
                print("Env.serviceProvider.liveSportTypes completed \(completion)")
                switch completion {
                case .finished:
                    ()
                case .failure:
                    self?.isLoading = false
                }
            }, receiveValue: { [weak self] (subscribableContent: SubscribableContent<[SportType]>) in
                switch subscribableContent {
                case .connected:
                    self?.configureWithLiveSports([])
                case .content(let sportTypes):
                    self?.configureWithLiveSports(sportTypes)
                case .disconnected:
                    self?.configureWithLiveSports([])
                }
            })
        
//        self.activityIndicatorView.isHidden = false
//
//        self.sportsData = Array(self.sportsRepository.sportsLive.values)
//        let sortedArray = self.sportsData.sorted(by: {$0.id.localizedStandardCompare($1.id) == .orderedAscending})
//        self.sportsData = sortedArray
//
//        self.fullSportsData = self.sportsData
//
//        self.collectionView.reloadData()
//
//        self.sportsRepository.changedSportsLivePublisher
//            .receive(on: DispatchQueue.main)
//            .sink(receiveValue: {[weak self] _ in
//                self?.updateSportsLiveCollection()
//            })
//            .store(in: &cancellable)
//        self.activityIndicatorView.isHidden = true

    }

    func configureWithLiveSports(_ sportTypes: [ServiceProvider.SportType]) {
        self.isLoading = true

        self.sportsData = sportTypes.map({ sportType in
            ServiceProviderModelMapper.liveSport(fromServiceProviderSportType: sportType)
        })

        self.fullSportsData = self.sportsData
        
        self.isLoading = false
        
        self.collectionView.reloadData()
    }

    // TODO: Fix updated live sports
    func updateSportsLiveCollection() {
//        self.sportsData = Array(self.sportsRepository.sportsLive.values)
//        let sortedArray = self.sportsData.sorted(by: {$0.id.localizedStandardCompare($1.id) == .orderedAscending})
//        self.sportsData = sortedArray
//
//        self.fullSportsData = self.sportsData
//
//        self.collectionView.reloadData()
    }

//    func configureWithAllSports(_ sportTypes: [ServiceProvider.SportTypeInfo]) {
//
        // TODO: Remove [EveryMatrix.Discipline] logic from this ViewModel, should be using the ServiceProvider models
//        // or another independent one
//        let sportsTypes = sportTypes.map { sportType in
//            EveryMatrix.Discipline(type: sportType.id,
//                                   id: sportType.id,
//                                   name: sportType.name,
//                                   numberOfLiveEvents: 0,
//                                   showEventCategory: false)
//        }

//        let sortedArray = sportsTypes.sorted(by: {$0.id.localizedStandardCompare($1.id) == .orderedAscending})
//        self.sportsData =
//
//        self.fullSportsData = self.sportsData
//
//        self.isLoading = false
//
//        self.collectionView.reloadData()
//    }

    func configureWithAllSports(_ sportTypes: [SportType]) {

        self.isLoading = true

//        let sortedArray = sportsTypes.sorted(by: {$0.id.localizedStandardCompare($1.id) == .orderedAscending})

        self.sportsData = sportTypes.map({ sportType in
            ServiceProviderModelMapper.sport(fromServiceProviderSportType: sportType)
        })

        self.fullSportsData = self.sportsData

        self.isLoading = false

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

        let viewModel = SportSelectionCollectionViewCellViewModel(sport: sport,
                                                                  isLive: isLiveSport)

        cell.configureCell(viewModel: viewModel)

        if cell.viewModel?.sport.id == self.defaultSport.id {
            cell.isSelected = true
            collectionView.selectItem(at: indexPath, animated: true, scrollPosition: UICollectionView.ScrollPosition.centeredHorizontally)
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

        self.dismiss(animated: true, completion: nil)
        AnalyticsClient.sendEvent(event: .selectedSport(sportId: self.defaultSport.id ))
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
