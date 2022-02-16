//
//  HistoryViewController.swift
//  ShowcaseProd
//
//  Created by Teresa on 14/02/2022.
//

import Foundation
import Combine
import UIKit

class HistoryViewController: UIViewController{


    // MARK: - Private Properties
    // Sub Views
    private lazy var navigationBaseView: UIView = Self.createNavigationView()
    private lazy var backImage: UIImageView = Self.createImageView()
    private lazy var optionSegmentControlBaseView: UIView = Self.createSimpleView()
    private lazy var optionSegmentControl: UISegmentedControl = Self.createSegmentedControl()
    private lazy var topLabel: UILabel = Self.createTopLabel()
    private lazy var topSliderSeparatorView: UIView = Self.createSimpleView()
    private lazy var topSliderView: UIView = Self.createSimpleView()
    private lazy var topSliderCollectionView: UICollectionView = Self.createTopSliderCollectionView()
    private lazy var filterBaseView : UIView = Self.createSimpleView()
    private lazy var filtersButtonImage: UIImageView = Self.createFilterImageView()
    private lazy var tableView: UITableView = Self.createTableView()
    private lazy var loadingBaseView: UIView = Self.createLoadingBaseView()
    private lazy var loadingActivityIndicatorView: UIActivityIndicatorView = Self.createLoadingActivityIndicatorView()

    // Logic
    private var cancellables: Set<AnyCancellable> = []
    private let viewModel: HistoryViewModel
    private var filterSelectedOption: Int = 0
    
    // MARK: - Lifetime and Cycle
    init(viewModel: HistoryViewModel = HistoryViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }


    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupSubviews()
        self.setupWithTheme()
    
        // Configure post-loading and self-dependent properties
        self.topSliderCollectionView.delegate = self
        self.topSliderCollectionView.dataSource = self

        self.tableView.delegate = self.viewModel
        self.tableView.dataSource = self.viewModel
        self.tableView.contentInset.bottom = 12
     
        
        self.topSliderCollectionView.register(ListTypeCollectionViewCell.nib, forCellWithReuseIdentifier: ListTypeCollectionViewCell.identifier)
        
        
       self.tableView.register(TransactionsTableViewCell.self, forCellReuseIdentifier: TransactionsTableViewCell.identifier)
        self.tableView.register(BettingsTableViewCell.self, forCellReuseIdentifier: BettingsTableViewCell.identifier)

        
        let tapFilterGesture = UITapGestureRecognizer(target: self, action: #selector(self.didTapFilterAction))
        self.filterBaseView.addGestureRecognizer(tapFilterGesture)
        self.filterBaseView.isUserInteractionEnabled = true
        self.filterBaseView.backgroundColor = UIColor.App.buttonBackgroundSecondary
        self.filterBaseView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        let tapBackGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        backImage.isUserInteractionEnabled = true
        backImage.addGestureRecognizer(tapBackGestureRecognizer)
        
        optionSegmentControl.addTarget(self, action: #selector(self.didChangeSegmentValue(_:)), for: .valueChanged)
      
        if filterSelectedOption == 0 {
            self.viewModel.myTicketsTypePublisher.send(.resolved)
           
        }
        self.tableView.reloadData()
    }

    // MARK: - Layout and Theme
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.filterBaseView.layer.cornerRadius = self.filterBaseView.frame.height / 2

    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    private func setupWithTheme() {
        self.view.backgroundColor = UIColor.App.backgroundPrimary

        self.tableView.backgroundColor = UIColor.App.backgroundPrimary
        self.tableView.backgroundView?.backgroundColor = UIColor.App.backgroundPrimary

        self.navigationBaseView.backgroundColor = UIColor.App.backgroundPrimary
        self.topSliderSeparatorView.backgroundColor = UIColor.App.separatorLine

        self.backImage.image = UIImage(named: "arrow_back_icon")
    
        self.topSliderCollectionView.backgroundView?.backgroundColor = .clear
        self.topSliderCollectionView.backgroundColor = UIColor.App.backgroundTertiary
        
        self.topLabel.textColor = UIColor.App.textPrimary
        
        self.filterBaseView.backgroundColor = UIColor.App.buttonBackgroundSecondary
        self.optionSegmentControl.setTitleTextAttributes([
            NSAttributedString.Key.font: AppFont.with(type: .bold, size: 13),
            NSAttributedString.Key.foregroundColor: UIColor.App.buttonTextPrimary
        ], for: .selected)
        self.optionSegmentControl.setTitleTextAttributes([
            NSAttributedString.Key.font: AppFont.with(type: .bold, size: 13),
            NSAttributedString.Key.foregroundColor: UIColor.App.buttonTextPrimary
        ], for: .normal)
        self.optionSegmentControl.setTitleTextAttributes([
            NSAttributedString.Key.font: AppFont.with(type: .bold, size: 13),
            NSAttributedString.Key.foregroundColor: UIColor.App.buttonTextPrimary.withAlphaComponent(0.5)
        ], for: .disabled)

        self.optionSegmentControl.selectedSegmentTintColor = UIColor.App.highlightPrimary
        self.optionSegmentControl.backgroundColor = UIColor.App.backgroundTertiary
   
    }

    // MARK: - Bindings
    private func bind(toViewModel viewModel: HistoryViewModel) {

        viewModel.refreshPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] in
                self?.tableView.reloadData()
                self?.topSliderCollectionView.reloadData()
            })
            .store(in: &self.cancellables)

    }

}

//
// MARK: - CollectionView Protocols
//

extension HistoryViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.viewModel.numberOfSections()
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel.numberOfShortcuts(forSection: section)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let cell = collectionView.dequeueCellType(ListTypeCollectionViewCell.self, indexPath: indexPath)
        else {
            fatalError()
        }
        cell.setupWithTitle( self.viewModel.shortcutTitle(forIndex: indexPath.row) ?? "")
        
        
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
        
        if self.optionSegmentControl.selectedSegmentIndex == 0 {
            self.viewModel.bettingTypeSelected.send(.none)
        }else{
            if indexPath.row == 0 {
                self.viewModel.bettingTypeSelected.send(.resolved)
                self.viewModel.myTicketsTypePublisher.send(.resolved)
            }else if indexPath.row == 1 {
                self.viewModel.bettingTypeSelected.send(.open)
                self.viewModel.myTicketsTypePublisher.send(.opened)
            }else if indexPath.row == 2 {
                self.viewModel.bettingTypeSelected.send(.won)
                self.viewModel.myTicketsTypePublisher.send(.won)
            }else if indexPath.row == 3 {
                self.viewModel.bettingTypeSelected.send(.cashout)
            }
        }
        
        self.viewModel.didSelectShortcut(atSection: indexPath.section)
        
        self.topSliderCollectionView.reloadData()
        self.tableView.reloadData()
        self.topSliderCollectionView.layoutIfNeeded()
        self.topSliderCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)

    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 2, bottom: 0, right: 2)
    }

}



//
// MARK: - Actions
//

extension HistoryViewController {
    /*
    @objc func didTapBetslipView() {
        self.didTapBetslipButtonAction?()
    }*/
     @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
     {
         self.dismiss(animated: true, completion: nil)
     // Your action
     }

    @objc func didTapFilterAction(sender: UITapGestureRecognizer) {
        print("clicou nos filtros")
    
    }

    
    @objc func didChangeSegmentValue(_ sender: UISegmentedControl) {
        if self.optionSegmentControl.selectedSegmentIndex == 0 {
            self.viewModel.listTypeSelected.send(.transactions)
        }else{
            self.viewModel.listTypeSelected.send(.bettings)
        }
    
        self.filterSelectedOption = 0
        self.viewModel.bettingTypeSelected.send(.resolved)
        self.topSliderCollectionView.reloadData()
        self.tableView.reloadData()
        
    }

}


//
// MARK: - Subviews Initialization and Setup
//
extension HistoryViewController {

    private static func createNavigationView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createSimpleView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createFilterImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.image = UIImage(named: "match_filters_icons")

        return imageView
    }
    
    private static func createImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }
    
    private static func createSegmentedControl() -> UISegmentedControl {
        let segment = UISegmentedControl(items: ["Transactions","Betting"])
        segment.translatesAutoresizingMaskIntoConstraints = false
        segment.selectedSegmentIndex = 0
        return segment
    }
    
    private static func createTopLabel() -> UILabel {
        let label = UILabel()
        label.text = localized("history")
        label.font = AppFont.with(type: .bold, size: 17)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
 
    private static func createTopSliderCollectionView() -> UICollectionView {
          let collectionLayout = UICollectionViewFlowLayout()
          collectionLayout.scrollDirection = .horizontal
          collectionLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize

          let collectionView = UICollectionView.init(frame: .zero, collectionViewLayout: collectionLayout)
          collectionView.translatesAutoresizingMaskIntoConstraints = false
          collectionView.showsVerticalScrollIndicator = false
          collectionView.showsHorizontalScrollIndicator = false
          collectionView.alwaysBounceHorizontal = true
          collectionView.contentInset = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)

          return collectionView
      }

    private static func createTableView() -> UITableView {
        let tableView = UITableView.init(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.contentInset = .zero
        tableView.contentInsetAdjustmentBehavior = .never
        return tableView
    }




    private static func createLoadingBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createLoadingActivityIndicatorView() -> UIActivityIndicatorView {
        let activityIndicatorView = UIActivityIndicatorView.init(style: .large)
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.stopAnimating()
        return activityIndicatorView
    }

    private func setupSubviews() {

        // Add subviews to self.view or each other
        self.navigationBaseView.addSubview(self.topLabel)
        self.navigationBaseView.addSubview(self.backImage)
        
        
        self.view.addSubview(self.navigationBaseView)
        
        self.optionSegmentControlBaseView.addSubview(self.optionSegmentControl)
        
        self.view.addSubview(self.optionSegmentControlBaseView)
        
        self.topSliderView.addSubview(self.topSliderCollectionView)
        
        self.filterBaseView.addSubview(self.filtersButtonImage)
        
        self.topSliderView.addSubview(self.filterBaseView)
        
        self.view.addSubview(self.topSliderView)
        

        self.view.addSubview(self.tableView)

        //self.view.addSubview(self.loadingBaseView)
       // self.loadingBaseView.addSubview(self.loadingActivityIndicatorView)

        // Initialize constraints
        self.initConstraints()
    }

    private func initConstraints() {

        NSLayoutConstraint.activate([
            
            self.navigationBaseView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.navigationBaseView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.navigationBaseView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.navigationBaseView.heightAnchor.constraint(equalToConstant: 50),
            
            self.topLabel.heightAnchor.constraint(equalToConstant: 20),
            self.topLabel.centerXAnchor.constraint(equalTo: self.navigationBaseView.centerXAnchor),
            self.topLabel.topAnchor.constraint(equalTo: self.navigationBaseView.topAnchor, constant: 30),
            
            self.backImage.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16 ),
            self.backImage.heightAnchor.constraint(equalToConstant: 20),
            self.backImage.centerYAnchor.constraint(equalTo: self.topLabel.centerYAnchor),
            self.backImage.topAnchor.constraint(equalTo: self.navigationBaseView.topAnchor, constant: 30),
            

        ])

        NSLayoutConstraint.activate([
            
            self.optionSegmentControlBaseView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.optionSegmentControlBaseView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.optionSegmentControlBaseView.topAnchor.constraint(equalTo: self.navigationBaseView.bottomAnchor),
            self.optionSegmentControlBaseView.heightAnchor.constraint(equalToConstant: 70),
            
            self.optionSegmentControl.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
            self.optionSegmentControl.centerYAnchor.constraint(equalTo: self.optionSegmentControlBaseView.centerYAnchor),
            self.optionSegmentControl.centerXAnchor.constraint(equalTo: self.optionSegmentControlBaseView.centerXAnchor),

        ])
        
        
        NSLayoutConstraint.activate([
            
            self.topSliderView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.topSliderView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.topSliderView.topAnchor.constraint(equalTo: self.optionSegmentControlBaseView.bottomAnchor),
            self.topSliderView.heightAnchor.constraint(equalToConstant: 70),
            
            self.topSliderCollectionView.leadingAnchor.constraint(equalTo: self.topSliderView.leadingAnchor),
            self.topSliderCollectionView.trailingAnchor.constraint(equalTo: self.topSliderView.trailingAnchor),
            self.topSliderCollectionView.topAnchor.constraint(equalTo: self.topSliderView.topAnchor),
            self.topSliderCollectionView.bottomAnchor.constraint(equalTo: self.topSliderView.topAnchor, constant: 70),
            
            self.filterBaseView.widthAnchor.constraint(equalToConstant: 40),
            self.filterBaseView.heightAnchor.constraint(equalToConstant: 40),
            self.filterBaseView.trailingAnchor.constraint(equalTo: self.topSliderView.trailingAnchor),
            self.filterBaseView.centerYAnchor.constraint(equalTo: self.topSliderCollectionView.centerYAnchor),
            
            self.filtersButtonImage.bottomAnchor.constraint(equalTo: self.filterBaseView.bottomAnchor, constant: -8),
            self.filtersButtonImage.topAnchor.constraint(equalTo: self.filterBaseView.topAnchor, constant: 8),
            self.filtersButtonImage.trailingAnchor.constraint(equalTo: self.filterBaseView.trailingAnchor, constant: -4),
            self.filtersButtonImage.centerYAnchor.constraint(equalTo: self.filterBaseView.centerYAnchor),
            //self.filtersButtonImage.centerXAnchor.constraint(equalTo: self.filterBaseView.centerXAnchor),
            
        ])
        
        
        NSLayoutConstraint.activate([
            self.tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.tableView.topAnchor.constraint(equalTo: self.topSliderView.bottomAnchor, constant: 8),
            self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])

       /* NSLayoutConstraint.activate([
            self.loadingBaseView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.loadingBaseView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.loadingBaseView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.loadingBaseView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),

            self.loadingActivityIndicatorView.centerXAnchor.constraint(equalTo: self.loadingBaseView.centerXAnchor),
            self.loadingActivityIndicatorView.centerYAnchor.constraint(equalTo: self.loadingBaseView.centerYAnchor),
        ])
*/
    }

}

    
