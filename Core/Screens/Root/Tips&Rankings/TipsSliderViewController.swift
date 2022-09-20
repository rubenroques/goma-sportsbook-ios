//
//  TipsSliderViewController.swift
//  Sportsbook
//
//  Created by Ruben Roques on 09/09/2022.
//

import Foundation
import UIKit
import Combine

class TipsSliderViewModel {
    
    var featuredTips: [FeaturedTip]
    private var featuredTipCollectionCacheViewModel: [String: FeaturedTipCollectionViewModel] = [:]
    private var startIndex: Int
    private var cancellables = Set<AnyCancellable>()
    
    init(featuredTips: [FeaturedTip], startIndex: Int) {
        self.featuredTips = featuredTips
        self.startIndex = startIndex

    }

    func initialIndex() -> Int {
        return self.startIndex
    }
    
    func numberOfItems() -> Int {
        return featuredTips.count
    }

    func viewModel(forIndex index: Int) -> FeaturedTipCollectionViewModel? {
        guard
            let featuredTip = self.featuredTips[safe: index]
        else {
            return nil
        }

        let tipId = featuredTip.betId

        if let featuredTipCollectionViewModel = featuredTipCollectionCacheViewModel[tipId] {
            return featuredTipCollectionViewModel
        }
        else {
            let featuredTipCollectionViewModel = FeaturedTipCollectionViewModel(featuredTip: featuredTip, sizeType: .fullscreen)
            self.featuredTipCollectionCacheViewModel[tipId] = featuredTipCollectionViewModel
            return featuredTipCollectionViewModel
        }
    }
    
}

class TipsSliderViewController: UIViewController {
    
    // MARK: Public properties
    
    // MARK: Private properties
    private lazy var baseView: UIView = Self.createBaseView()
    
    private lazy var titleLabel: UIView = Self.createTitleLabel()
    private lazy var collectionView: UICollectionView = Self.createCollectionView()
    private lazy var closeButton: UIButton = Self.createCloseButton()
    
    private static let scrollViewMargin: CGFloat = 24
    
    private var viewModel: TipsSliderViewModel

    private var cancellables = Set<AnyCancellable>()

    var shouldShowBetslip: (() -> Void)?
    
    // MARK: - Lifetime and Cycle
    init(viewModel: TipsSliderViewModel) {
        
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        self.collectionView.register(FeaturedTipCollectionViewCell.self, forCellWithReuseIdentifier: FeaturedTipCollectionViewCell.identifier)
        
        self.closeButton.addTarget(self, action: #selector(self.didTapCloseButton), for: .primaryActionTriggered)
        
        let swipeDownGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(self.didTapCloseButton))
        swipeDownGestureRecognizer.direction = .down
        self.baseView.addGestureRecognizer(swipeDownGestureRecognizer)
        
        self.setupSubviews()
        self.setupWithTheme()

        self.setupPublishers()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
        self.collectionView.reloadData()
        self.collectionView.scrollToItem(at: IndexPath(row: self.viewModel.initialIndex(), section: 0),
                                         at: .centeredHorizontally,
                                         animated: false)
    }
    
    // MARK: - Layout and Theme
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    private func setupWithTheme() {
        self.view.backgroundColor = .clear
        
        self.collectionView.backgroundView?.backgroundColor = .clear
        self.collectionView.backgroundColor = .clear
        
        self.closeButton.tintColor = .white
        self.baseView.backgroundColor = .clear
    }

    // MARK: Functions
    private func setupPublishers() {

        Env.gomaSocialClient.followingUsersPublisher
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                self?.collectionView.reloadData()
            })
            .store(in: &cancellables)
    }

    // MARK: Actions
    @objc func didTapCloseButton() {
        self.dismiss(animated: true)
    }
}

extension TipsSliderViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel.numberOfItems()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let cell = collectionView.dequeueCellType(FeaturedTipCollectionViewCell.self, indexPath: indexPath),
            let cellViewModel = self.viewModel.viewModel(forIndex: indexPath.row)
        else {
            fatalError()
        }
        cell.configure(viewModel: cellViewModel, hasCounter: false, followingUsers: Env.gomaSocialClient.followingUsersPublisher.value)

        cell.shouldShowBetslip = { [weak self] in
            self?.shouldShowBetslip?()
            self?.dismiss(animated: true)
        }

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width - (Self.scrollViewMargin * 2), height: collectionView.frame.size.height * 0.9)
    }
    
}
    
extension TipsSliderViewController {
    
    private static func createBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let blurEffect = UIBlurEffect(style: .regular)
        
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        
        // If you have more UIViews, use an insertSubview API to place it where needed
        view.insertSubview(blurEffectView, at: 0)

        NSLayoutConstraint.activate([
            blurEffectView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            blurEffectView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            blurEffectView.topAnchor.constraint(equalTo: view.topAnchor),
            blurEffectView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
        return view
    }

    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.font = AppFont.with(type: .bold, size: 20)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Featured Tips"
        label.numberOfLines = 2
        return label
    }
    
    private static func createCollectionView() -> UICollectionView {

//        let layout = UICollectionViewFlowLayout()
//        layout.scrollDirection = .horizontal
//        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize

        let flowLayout = FadeInCenterHorizontalFlowLayout()
        flowLayout.alpha = 1.0
        flowLayout.minimumScale = 0.67
        flowLayout.scrollDirection = .horizontal
        // flowLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        
        let collectionView = UICollectionView.init(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceHorizontal = true
        collectionView.decelerationRate = .fast
        collectionView.contentInset = UIEdgeInsets(top: 0, left: Self.scrollViewMargin, bottom: 0, right: Self.scrollViewMargin)
        
        return collectionView
    }
    
    private static func createCloseButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.clipsToBounds = true
        
        let config = UIImage.SymbolConfiguration(pointSize: 42, weight: .medium, scale: .default)
        let image = UIImage(systemName: "multiply.circle", withConfiguration: config)
        
        button.setImage(image, for: .normal)
        button.tintColor = .red
        return button
    }
    
    private func setupSubviews() {
        
        self.view.addSubview(self.baseView)
        
        self.baseView.addSubview(self.titleLabel)
        self.baseView.addSubview(self.collectionView)
        self.baseView.addSubview(self.closeButton)
        
        self.initConstraints()
    }

    private func initConstraints() {
        
        NSLayoutConstraint.activate([
            self.baseView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.baseView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.baseView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            self.baseView.topAnchor.constraint(equalTo: self.view.topAnchor),
        ])
        
        NSLayoutConstraint.activate([
            self.titleLabel.centerXAnchor.constraint(equalTo: self.baseView.centerXAnchor),
            self.titleLabel.topAnchor.constraint(equalTo: self.baseView.safeAreaLayoutGuide.topAnchor, constant: 16),
            self.titleLabel.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        NSLayoutConstraint.activate([
            self.closeButton.centerXAnchor.constraint(equalTo: self.baseView.centerXAnchor),
            self.closeButton.bottomAnchor.constraint(equalTo: self.baseView.safeAreaLayoutGuide.bottomAnchor, constant: -24),
        ])
        
        NSLayoutConstraint.activate([
            self.collectionView.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor),
            self.collectionView.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor),
            self.collectionView.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 8),
            self.collectionView.bottomAnchor.constraint(equalTo: self.closeButton.topAnchor, constant: -12),
        ])
        
    }
    
}

