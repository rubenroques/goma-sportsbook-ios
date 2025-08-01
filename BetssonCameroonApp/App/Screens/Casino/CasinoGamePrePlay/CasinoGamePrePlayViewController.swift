//
//  CasinoGamePrePlayViewController.swift
//  BetssonCameroonApp
//
//  Created by Ruben Roques on 01/08/2025.
//

import UIKit
import Combine
import GomaUI

class CasinoGamePrePlayViewController: UIViewController {
    
    // MARK: - UI Components
    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let overlayView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        return view
    }()
    
    private let navigationView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let navigationTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .bold, size: 16)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.tintColor = .white
        return button
    }()
    
    private let favoritesButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "heart"), for: .normal)
        button.setImage(UIImage(systemName: "heart.fill"), for: .selected)
        button.tintColor = .white
        return button
    }()
    
    private let playSelectorView: CasinoGamePlayModeSelectorView
    
    private let loadingIndicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = .white
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.startAnimating()
        
        view.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        return view
    }()
    
    // MARK: - Properties
    let viewModel: CasinoGamePrePlayViewModel
    private var cancellables = Set<AnyCancellable>()
    private var isFavorite: Bool = false
    
    // MARK: - Lifecycle
    init(viewModel: CasinoGamePrePlayViewModel) {
        self.viewModel = viewModel
        self.playSelectorView = CasinoGamePlayModeSelectorView(viewModel: viewModel.playSelectorViewModel)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupBindings()
        setupActions()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Setup
    private func setupViews() {
        view.backgroundColor = .black
        
        setupBackgroundImage()
        setupOverlay()
        setupNavigationView()
        setupPlaySelectorView()
        setupLoadingIndicator()
        setupConstraints()
    }
    
    private func setupBackgroundImage() {
        view.addSubview(backgroundImageView)
    }
    
    private func setupOverlay() {
        view.addSubview(overlayView)
    }
    
    private func setupNavigationView() {
        view.addSubview(navigationView)
        navigationView.addSubview(navigationTitleLabel)
        navigationView.addSubview(backButton)
        navigationView.addSubview(favoritesButton)
    }
    
    private func setupActions() {
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        favoritesButton.addTarget(self, action: #selector(favoritesButtonTapped), for: .touchUpInside)
    }
    
    private func setupPlaySelectorView() {
        playSelectorView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(playSelectorView)
    }
    
    private func setupLoadingIndicator() {
        view.addSubview(loadingIndicatorView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Background Image - full screen
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Overlay - covers background
            overlayView.topAnchor.constraint(equalTo: view.topAnchor),
            overlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            overlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Navigation View
            navigationView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navigationView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            navigationView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            navigationView.heightAnchor.constraint(equalToConstant: 44),
            
            // Back Button (left side)
            backButton.leadingAnchor.constraint(equalTo: navigationView.leadingAnchor, constant: 16),
            backButton.centerYAnchor.constraint(equalTo: navigationView.centerYAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 44),
            backButton.heightAnchor.constraint(equalToConstant: 44),
            
            // Favorites Button (right side)
            favoritesButton.trailingAnchor.constraint(equalTo: navigationView.trailingAnchor, constant: -16),
            favoritesButton.centerYAnchor.constraint(equalTo: navigationView.centerYAnchor),
            favoritesButton.widthAnchor.constraint(equalToConstant: 44),
            favoritesButton.heightAnchor.constraint(equalToConstant: 44),
            
            // Navigation Title (centered with padding for buttons)
            navigationTitleLabel.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 8),
            navigationTitleLabel.trailingAnchor.constraint(equalTo: favoritesButton.leadingAnchor, constant: -8),
            navigationTitleLabel.centerYAnchor.constraint(equalTo: navigationView.centerYAnchor),
            
            // Play Selector View
            playSelectorView.topAnchor.constraint(equalTo: navigationView.bottomAnchor),
            playSelectorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            playSelectorView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            playSelectorView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Loading Indicator
            loadingIndicatorView.topAnchor.constraint(equalTo: view.topAnchor),
            loadingIndicatorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingIndicatorView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loadingIndicatorView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - Bindings
    private func setupBindings() {
        // Loading state
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                self?.loadingIndicatorView.isHidden = !isLoading
            }
            .store(in: &cancellables)
        
        // Error handling
        viewModel.$errorMessage
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorMessage in
                self?.showError(errorMessage)
            }
            .store(in: &cancellables)
        
        // Game data binding for navigation title and background
        viewModel.playSelectorViewModel.displayStatePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] displayState in
                self?.navigationTitleLabel.text = displayState.gameData.provider
                self?.loadBackgroundImage(from: displayState.gameData.imageURL)
            }
            .store(in: &cancellables)
        
        // Play selector callbacks
        playSelectorView.onButtonTapped = { [weak self] buttonId in
            print("CasinoGamePrePlay: Button tapped - \(buttonId)")
        }
        
        playSelectorView.onRefreshRequested = { [weak self] in
            self?.viewModel.refreshData()
        }
    }
    
    private func loadBackgroundImage(from urlString: String?) {
        guard let urlString = urlString, let url = URL(string: urlString) else {
            backgroundImageView.image = nil
            return
        }
        
        // Simple image loading - in production you'd use a proper image loading library
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let data = data, let image = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                self?.backgroundImageView.image = image
            }
        }.resume()
    }
    
    // MARK: - Error Handling
    private func showError(_ message: String) {
        let alert = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        alert.addAction(UIAlertAction(title: "Retry", style: .default) { [weak self] _ in
            self?.viewModel.refreshData()
        })
        
        present(alert, animated: true)
    }
    
    // MARK: - Actions
    @objc private func backButtonTapped() {
        viewModel.navigateBack()
    }
    
    @objc private func favoritesButtonTapped() {
        isFavorite.toggle()
        favoritesButton.isSelected = isFavorite
        
        // TODO: Add to/remove from favorites via viewModel
        print("Game \(isFavorite ? "added to" : "removed from") favorites")
    }
}