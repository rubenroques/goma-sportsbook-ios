//
//  MatchDetailsViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 23/11/2021.
//

import UIKit

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

    enum MatchMode {
        case preLive
        case live
    }

    var matchMode: MatchMode {
        didSet {
            if matchMode == .preLive {
                self.headerDetailLiveView.isHidden = true

            }
            else {
                self.headerDetailPreliveView.isHidden = true
            }
        }
    }

    var match: Match
    var marketTypeSelectedOption: Int = 0

    init(matchMode: MatchMode = .preLive, match: Match) {
        self.matchMode = matchMode
        self.match = match
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
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    func commonInit() {
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

        self.headerDetailLiveBottomLabel.text = "Part Time"
        self.headerDetailLiveBottomLabel.font = AppFont.with(type: .semibold, size: 12)

        if self.matchMode == .preLive {
            self.headerDetailLiveView.isHidden = true
        }
        else {
            self.headerDetailPreliveView.isHidden = true
        }

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
        self.marketTypesCollectionView.delegate = self
        self.marketTypesCollectionView.dataSource = self
        
    }

    func setupWithTheme() {

        self.view.backgroundColor = UIColor.App.mainBackground

        self.topView.backgroundColor = UIColor.App.mainBackground

        self.headerDetailView.backgroundColor = UIColor.App.secondaryBackground

        self.headerDetailTopView.backgroundColor = UIColor.App.secondaryBackground

        self.backButton.tintColor = UIColor.App.headingMain

        self.headerCompetitionDetailView.backgroundColor = UIColor.App.secondaryBackground

        self.headerCompetitionLabel.textColor = UIColor.App.headingMain.withAlphaComponent(0.5)

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
            //TO-DO Live match
        }
    }

    @IBAction func backAction() {
        self.navigationController?.popViewController(animated: true)
    }

}

extension MatchDetailsViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let cell = collectionView.dequeueCellType(ListTypeCollectionViewCell.self, indexPath: indexPath)
        else {
            fatalError()
        }

        switch indexPath.row {
        case 0:
            cell.setupWithTitle("Popular")
        case 1:
            cell.setupWithTitle("Goals")
        case 2:
            cell.setupWithTitle("Results")
        case 3:
            cell.setupWithTitle("Handycap")
        default:
            ()
        }

        if marketTypeSelectedOption == indexPath.row {
            cell.setSelectedType(true)
        }
        else {
            cell.setSelectedType(false)
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        self.marketTypeSelectedOption = indexPath.row

        switch indexPath.row {
        case 0:
            // Model for tab
            break
        case 1:
            // Model for tab
            break
        case 2:
            // Model for tab
            break
        case 3:
            // Model for tab
            break
        default:
            ()
        }

        self.marketTypesCollectionView.reloadData()
        self.marketTypesCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }

}
