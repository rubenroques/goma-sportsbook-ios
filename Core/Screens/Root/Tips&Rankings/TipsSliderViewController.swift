//
//  TipsSliderViewController.swift
//  Sportsbook
//
//  Created by Ruben Roques on 09/09/2022.
//

import Foundation
import UIKit

class TipsSliderViewModel {
    
    var featuredTips: [FeaturedTip]
    private var featuredTipCollectionCacheViewModel: [String: FeaturedTipCollectionViewModel] = [:]
    private var startIndex: Int
    
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
    private lazy var blurEffectView: UIVisualEffectView = Self.createBlurEffectView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var collectionView: UICollectionView = Self.createCollectionView()
    private lazy var closeButton: UIButton = Self.createCloseButton()
    
    private lazy var arrowRightImageView: UIImageView = Self.createArrowRightImageView()
    private lazy var arrowLeftImageView: UIImageView = Self.createArrowLeftImageView()
    
    private static let scrollViewMargin: CGFloat = 28
    
    private var viewModel: TipsSliderViewModel
    
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
        
        // self.blurEffectView.effect = nil
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
//        UIView.animate(withDuration: 1) {
//            self.blurEffectView.effect = UIBlurEffect(style: UIBlurEffect.Style.prominent)
//        }
        
        self.collectionView.reloadData()
        self.collectionView.layoutIfNeeded()
        self.collectionView.scrollToItem(at: IndexPath(row: self.viewModel.initialIndex(), section: 0),
                                         at: .centeredHorizontally,
                                         animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: 0.2, delay: 0.6, options: .curveEaseOut, animations: {
            self.arrowRightImageView.alpha = 0.0
            self.arrowLeftImageView.alpha = 0.0
        }, completion: nil )
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
        
        self.closeButton.tintColor = UIColor.App.textPrimary
        
        self.titleLabel.textColor = UIColor.App.textPrimary
        
        self.arrowRightImageView.tintColor = UIColor.App.textPrimary
        self.arrowLeftImageView.tintColor = UIColor.App.textPrimary
        
        self.baseView.backgroundColor = UIColor.App.backgroundPrimary.withAlphaComponent(0.96) // .clear
    }
    
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
            let viewModel = self.viewModel.viewModel(forIndex: indexPath.row)
        else {
            fatalError()
        }
        
        cell.configure(viewModel: viewModel, hasCounter: false)
        cell.configureAnimationId("FeaturedTipCell\(indexPath.row)")
        
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
        return view
    }

    private static func createBlurEffectView() -> UIVisualEffectView {

        let blurEffect = UIBlurEffect(style: .regular)
        
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        
        return blurEffectView
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
    
    private static func createArrowRightImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium, scale: .default)
        let image = UIImage(systemName: "chevron.right", withConfiguration: config)
        
        imageView.image = image
        imageView.alpha = 0.8
        return imageView
    }

    private static func createArrowLeftImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium, scale: .default)
        let image = UIImage(systemName: "chevron.left", withConfiguration: config)
        
        imageView.image = image
        imageView.alpha = 0.8
        return imageView
    }
    
    private func setupSubviews() {
        
        self.view.addSubview(self.baseView)
        
        self.baseView.addSubview(self.blurEffectView)
        self.baseView.addSubview(self.titleLabel)
        self.baseView.addSubview(self.collectionView)
        self.baseView.addSubview(self.closeButton)
        
        self.baseView.addSubview(self.arrowLeftImageView)
        self.baseView.addSubview(self.arrowRightImageView)
        
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
            self.blurEffectView.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor),
            self.blurEffectView.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor),
            self.blurEffectView.topAnchor.constraint(equalTo: self.baseView.topAnchor),
            self.blurEffectView.bottomAnchor.constraint(equalTo: self.baseView.bottomAnchor),
        ])

        NSLayoutConstraint.activate([
            self.titleLabel.centerXAnchor.constraint(equalTo: self.baseView.centerXAnchor),
            self.titleLabel.topAnchor.constraint(equalTo: self.baseView.safeAreaLayoutGuide.topAnchor, constant: 16),
            self.titleLabel.heightAnchor.constraint(equalToConstant: 40),
            
            self.arrowLeftImageView.centerYAnchor.constraint(equalTo: self.baseView.centerYAnchor),
            self.arrowLeftImageView.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor, constant: 8),
            self.arrowRightImageView.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor, constant: -8),
            self.arrowRightImageView.centerYAnchor.constraint(equalTo: self.arrowLeftImageView.centerYAnchor),
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

