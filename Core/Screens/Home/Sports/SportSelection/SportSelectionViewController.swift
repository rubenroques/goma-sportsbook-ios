//
//  SportSelectionViewController.swift
//  ShowcaseProd
//
//  Created by André Lascas on 11/10/2021.
//

import UIKit
import Combine

class SportSelectionViewController: UIViewController {

    @IBOutlet private var topView: UIView!
    @IBOutlet private var navigationView: UIView!
    @IBOutlet private var navigationLabel: UILabel!
    @IBOutlet private var cancelButton: UIButton!
    @IBOutlet private var collectionView: UICollectionView!
    @IBOutlet private var searchBar: UISearchBar!

    // Variables
    weak var delegate: SportTypeSelectionViewDelegate?
    private var cancellable = Set<AnyCancellable>()

    var sportsData: [EveryMatrix.Discipline] = []
    var fullSportsData: [EveryMatrix.Discipline] = []
    var defaultSport: String = ""
    
    init(defaultSport: String) {
        self.defaultSport = defaultSport
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

        getSports()

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
//        self.searchBar.tintColor = .blue
//        self.searchBar.barTintColor = .red
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

        let sports = EveryMatrixAPIClient().getDisciplinesData(payload: ["lang": "en"])

        sports.receive(on: RunLoop.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure:
                    print("Error retrieving data!")
                case .finished:
                    print("Data retrieved!")
                }
            }, receiveValue: { value in
                self.sportsData = value.records ?? []
                self.fullSportsData = self.sportsData
                self.collectionView.reloadData()
            })
            .store(in: &self.cancellable)

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
        cell.setSport(sport: sportsData[indexPath.row])
        if cell.sport?.id == self.defaultSport {
            cell.isSelected = true
            collectionView.selectItem(at: indexPath, animated: true, scrollPosition: UICollectionView.ScrollPosition.centeredHorizontally)
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.sportsData.count
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! SportSelectionCollectionViewCell
        cell.isSelected = true
        self.defaultSport = cell.sport?.id ?? ""
        delegate?.setSport(sport: self.defaultSport)
        self.dismiss(animated: true, completion: nil)
        AnalyticsClient.sendEvent(event: .selectedSport(sportId: self.defaultSport ))
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
