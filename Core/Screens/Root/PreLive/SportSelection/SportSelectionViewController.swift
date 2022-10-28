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
    @IBOutlet private var activityIndicatorView: UIActivityIndicatorView!

    // Variables
    var sportsData: [EveryMatrix.Discipline] = []
    var fullSportsData: [EveryMatrix.Discipline] = []
    var defaultSport: Sport
    var isLiveSport: Bool
    var sportsRepository: SportsAggregatorRepository

    var allSportsPublisher: AnyCancellable?
    var allSportsRegister: EndpointPublisherIdentifiable?

    var liveSportsPublisher: AnyCancellable?
    var liveSportsRegister: EndpointPublisherIdentifiable?

    var liveSportsDetailsCancellable: AnyCancellable?
    
    var selectionDelegate: SportTypeSelectionViewDelegate?
    
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
        
        self.activityIndicatorView.isHidden = true
        self.view.bringSubviewToFront(self.activityIndicatorView)

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

        self.allSportsPublisher?.cancel()
        self.allSportsPublisher = nil

        self.allSportsPublisher = Env.serviceProvider.allSportTypes()?
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                print("Env.serviceProvider.allSportTypes completed \(completion)")
            }, receiveValue: { [weak self] (subscribableContent: SubscribableContent<[SportType]>) in
                switch subscribableContent {
                case .connected:
                    print("Env.serviceProvider.allSportTypes connected")
                    // self?.configureWithAllSports([])
                case .content(let sportTypes):
                    print("Env.serviceProvider.allSportTypes content")
                    self?.configureWithAllSports(sportTypes)
                case .disconnected:
                    print("Env.serviceProvider.allSportTypes disconnected")
                    //self?.configureWithAllSports([])
                }
            })

        // EM TEMP SHUTDOWN
//        self.sportsData = []
//        self.fullSportsData = []
//        self.activityIndicatorView.isHidden = true
//        self.collectionView.reloadData()
    }

    func getSportsLive() {
        
        self.liveSportsPublisher?.cancel()
        self.liveSportsPublisher = nil

        self.liveSportsPublisher = Env.serviceProvider.liveSportTypes()?
            .sink(receiveCompletion: { completion in
                print("Env.serviceProvider.liveSportTypes completed \(completion)")
            }, receiveValue: { [weak self] (subscribableContent: SubscribableContent<[SportTypeDetails]>) in
                switch subscribableContent {
                case .connected:
                    self?.configureWithLiveSportsDetails([])
                case .content(let sportTypeDetails):
                    self?.configureWithLiveSportsDetails(sportTypeDetails)
                case .disconnected:
                    self?.configureWithLiveSportsDetails([])
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

    func configureWithLiveSportsDetails(_ sportTypeDetails: [ServiceProvider.SportTypeDetails]) {
        
        // TODO: Remove [EveryMatrix.Discipline] logic from this ViewModel, should be using the ServiceProvider models
        // or another independent one
        let sportsTypes = sportTypeDetails.map { sportTypeDetails in
            EveryMatrix.Discipline(type: sportTypeDetails.sportType.id,
                                   id: sportTypeDetails.sportType.id,
                                   name: sportTypeDetails.sportType.name,
                                   numberOfLiveEvents: sportTypeDetails.eventsCount,
                                   showEventCategory: false)
        }
        
        let sortedArray = sportsTypes.sorted(by: {$0.id.localizedStandardCompare($1.id) == .orderedAscending})
        self.sportsData = sortedArray

        self.fullSportsData = self.sportsData
        
        self.activityIndicatorView.isHidden = true
        
        self.collectionView.reloadData()
    }
    
    func updateSportsLiveCollection() {
        self.sportsData = Array(self.sportsRepository.sportsLive.values)
        let sortedArray = self.sportsData.sorted(by: {$0.id.localizedStandardCompare($1.id) == .orderedAscending})
        self.sportsData = sortedArray

        self.fullSportsData = self.sportsData

        self.collectionView.reloadData()
    }

    func configureWithAllSports(_ sportTypes: [ServiceProvider.SportType]) {

        // TODO: Remove [EveryMatrix.Discipline] logic from this ViewModel, should be using the ServiceProvider models
        // or another independent one
        let sportsTypes = sportTypes.map { sportType in
            EveryMatrix.Discipline(type: sportType.id,
                                   id: sportType.id,
                                   name: sportType.name,
                                   numberOfLiveEvents: 0,
                                   showEventCategory: false)
        }

        let sortedArray = sportsTypes.sorted(by: {$0.id.localizedStandardCompare($1.id) == .orderedAscending})
        self.sportsData = sortedArray

        self.fullSportsData = self.sportsData

        self.activityIndicatorView.isHidden = true

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
            let cell = collectionView.dequeueCellType(SportSelectionCollectionViewCell.self, indexPath: indexPath)
        else {
            fatalError()
        }

        // TODO: Refactor this logic to the CellViewModel
        let viewModel = SportSelectionCollectionViewCellViewModel(sport: sportsData[indexPath.row],
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
            let sportTypeAtIndex = sportsData[safe: indexPath.row],
            let cell = collectionView.cellForItem(at: indexPath) as? SportSelectionCollectionViewCell
        else {
            collectionView.deselectItem(at: indexPath, animated: true)
            return
        }

        let selectedSport = Sport(id: sportTypeAtIndex.id,
                          name: sportTypeAtIndex.name ?? "",
                          showEventCategory: sportTypeAtIndex.showEventCategory ?? false)

        cell.isSelected = true
        self.defaultSport = selectedSport

        self.selectionDelegate?.selectedSport(selectedSport)

        self.dismiss(animated: true, completion: nil)
        AnalyticsClient.sendEvent(event: .selectedSport(sportId: self.defaultSport.id ))
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        self.sportsData.removeAll()

        if !searchText.isEmpty {
            for sport in self.fullSportsData {
                if sport.name!.lowercased().contains(searchText.lowercased()) {
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
