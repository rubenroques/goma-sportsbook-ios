//
//  SportSelectionViewController.swift
//  ShowcaseProd
//
//  Created by André Lascas on 11/10/2021.
//

import UIKit
import Combine


protocol SportTypeSelectionViewDelegate: AnyObject {
    func setSportType(_ sportType: SportType)
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
    var defaultSport: SportType
    var isLiveSport: Bool
    var sportsRepository: SportsAggregatorRepository

    var liveSportsPublisher: AnyCancellable?
    var liveSportsRegister: EndpointPublisherIdentifiable?

    var selectionDelegate: SportTypeSelectionViewDelegate?
    
    private var cancellable = Set<AnyCancellable>()

    init(defaultSport: SportType, isLiveSport: Bool = false, sportsRepository: SportsAggregatorRepository = SportsAggregatorRepository()) {
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

    func commonInit() {
        
        self.activityIndicatorView.isHidden = true
        self.view.bringSubviewToFront(self.activityIndicatorView)

        if isLiveSport {
            getSportsLive()
        }
        else {
            getSports()
        }

        navigationLabel.text = localized("string_choose_sport")
        navigationLabel.font = AppFont.with(type: .bold, size: 16)

        cancelButton.setTitle(localized("string_cancel"), for: .normal)
        cancelButton.titleLabel?.font = AppFont.with(type: .semibold, size: 16)

        collectionView.register(SportSelectionCollectionViewCell.nib,
                                       forCellWithReuseIdentifier: SportSelectionCollectionViewCell.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self

        searchBar.delegate = self

    }

    func setupWithTheme() {

        self.view.backgroundColor = UIColor.App.mainBackground
        topView.backgroundColor = UIColor.App.mainBackground
        navigationView.backgroundColor = UIColor.App.mainBackground
        navigationLabel.textColor = UIColor.App.headingMain
        cancelButton.setTitleColor(UIColor.App.mainTint, for: .normal)
        collectionView.backgroundColor = UIColor.App.mainBackground

        self.searchBar.searchBarStyle = UISearchBar.Style.prominent
        self.searchBar.sizeToFit()
        self.searchBar.isTranslucent = false
        self.searchBar.backgroundImage = UIImage()
        self.searchBar.backgroundImage = UIColor.App.mainBackground.image()
        self.searchBar.placeholder = localized("string_search")

        self.searchBar.delegate = self

        if let textfield = searchBar.value(forKey: "searchField") as? UITextField {
            textfield.backgroundColor = UIColor.App.secondaryBackground
            textfield.textColor = .white
            textfield.tintColor = .white
            textfield.attributedPlaceholder = NSAttributedString(string: localized("string_search_field"),
                                                                 attributes: [NSAttributedString.Key.foregroundColor:
                                                                                UIColor.App.fadeOutHeading])

            if let glassIconView = textfield.leftView as? UIImageView {
                glassIconView.image = glassIconView.image?.withRenderingMode(.alwaysTemplate)
                glassIconView.tintColor = UIColor.App.fadeOutHeading
            }
        }

    }

    func getSports() {

        self.activityIndicatorView.isHidden = false

        let sports = EveryMatrixServiceClient().getDisciplinesData(payload: ["lang": "en"])

        sports
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure:
                    print("Error retrieving data!")
                case .finished:
                    print("Data retrieved!")
                }
                self.activityIndicatorView.isHidden = true
            }, receiveValue: { value in
                self.sportsData = value.records ?? []
                self.fullSportsData = self.sportsData
                self.collectionView.reloadData()
            })
            .store(in: &self.cancellable)

    }

    func getSportsLive() {
        self.activityIndicatorView.isHidden = false

        self.sportsData = Array(self.sportsRepository.sportsLive.values)
        let sortedArray = self.sportsData.sorted(by: {$0.id?.localizedStandardCompare($1.id ?? "1") == .orderedAscending})
        self.sportsData = sortedArray

        self.fullSportsData = self.sportsData

        self.collectionView.reloadData()

        self.sportsRepository.changedSportsLivePublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: {[weak self] _ in
                self?.updateSportsLiveCollection()
            })
            .store(in: &cancellable)
        self.activityIndicatorView.isHidden = true

    }

    func updateSportsLiveCollection() {
        self.sportsData = Array(self.sportsRepository.sportsLive.values)
        let sortedArray = self.sportsData.sorted(by: {$0.id?.localizedStandardCompare($1.id ?? "1") == .orderedAscending})
        self.sportsData = sortedArray

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
            let cell = collectionView.dequeueCellType(SportSelectionCollectionViewCell.self, indexPath: indexPath)
        else {
            fatalError()
        }

        let viewModel = SportSelectionCollectionViewCellViewModel(sport: sportsData[indexPath.row])

        cell.configureCell(viewModel: viewModel)

        if cell.viewModel?.sport.id == self.defaultSport.typeId {
            cell.isSelected = true
            collectionView.selectItem(at: indexPath, animated: true, scrollPosition: UICollectionView.ScrollPosition.centeredHorizontally)
        }
        if isLiveSport {
            cell.viewModel?.setSportPublisher(sportsRepository: self.sportsRepository)
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.sportsData.count
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        guard
            let sportTypeAtIndex = sportsData[safe:indexPath.row],
            let sportTypeIdAtIndex = sportTypeAtIndex.id,
            let newSportType = SportType(id: sportTypeIdAtIndex),
            let cell = collectionView.cellForItem(at: indexPath) as? SportSelectionCollectionViewCell
        else {
            collectionView.deselectItem(at: indexPath, animated: true)
            return
        }

        cell.isSelected = true
        self.defaultSport = newSportType

        selectionDelegate?.setSportType(self.defaultSport)

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
