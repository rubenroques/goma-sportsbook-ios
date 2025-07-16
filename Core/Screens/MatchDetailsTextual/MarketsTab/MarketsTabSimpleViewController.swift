//
//  MarketsTabSimpleViewController.swift
//  Sportsbook
//
//  Created on 2025-07-16.
//

import UIKit
import Combine

public class MarketsTabSimpleViewController: UIViewController {
    
    // MARK: - Properties
    
    public let marketGroupId: String
    public let marketGroupTitle: String
    private let viewModel: MarketsTabSimpleViewModelProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Components
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let mainStackView = UIStackView()
    private let loadingIndicator = UIActivityIndicatorView(style: .medium)
    
    // MARK: - Initialization
    
    public init(marketGroupId: String, title: String) {
        self.marketGroupId = marketGroupId
        self.marketGroupTitle = title
        self.viewModel = MockMarketsTabSimpleViewModel.defaultMock(for: marketGroupId, title: title)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupBindings()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Configure scroll view
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        scrollView.alwaysBounceVertical = true
        
        // Configure content view
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        // Configure main stack view
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        mainStackView.axis = .vertical
        mainStackView.spacing = 16
        mainStackView.alignment = .fill
        mainStackView.distribution = .fill
        
        // Configure loading indicator
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.hidesWhenStopped = true
        
        // Add views to hierarchy
        view.addSubview(scrollView)
        view.addSubview(loadingIndicator)
        scrollView.addSubview(contentView)
        contentView.addSubview(mainStackView)
        
        // Setup content
        setupContent()
    }
    
    private func setupContent() {
        // Title section
        let titleLabel = UILabel()
        titleLabel.text = marketGroupTitle
        titleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        titleLabel.textColor = .label
        titleLabel.textAlignment = .center
        
        // Subtitle
        let subtitleLabel = UILabel()
        subtitleLabel.text = "Market Group ID: \(marketGroupId)"
        subtitleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.textAlignment = .center
        
        // Description
        let descriptionLabel = UILabel()
        descriptionLabel.text = "This is a simple dummy placeholder view for the \(marketGroupTitle) market group."
        descriptionLabel.font = .systemFont(ofSize: 14, weight: .regular)
        descriptionLabel.textColor = .label
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = .center
        
        // Sample content cards
        let sampleCards = createSampleCards()
        
        // Add components to stack view
        mainStackView.addArrangedSubview(titleLabel)
        mainStackView.addArrangedSubview(subtitleLabel)
        mainStackView.addArrangedSubview(createSpacer(height: 20))
        mainStackView.addArrangedSubview(descriptionLabel)
        mainStackView.addArrangedSubview(createSpacer(height: 20))
        
        for card in sampleCards {
            mainStackView.addArrangedSubview(card)
        }
        
        // Add bottom spacer
        mainStackView.addArrangedSubview(createSpacer(height: 40))
    }
    
    private func createSampleCards() -> [UIView] {
        var cards: [UIView] = []
        
        let sampleMarkets = [
            "Full Time Result",
            "Both Teams to Score",
            "Over/Under 2.5 Goals",
            "Handicap",
            "Correct Score"
        ]
        
        for (index, marketName) in sampleMarkets.enumerated() {
            let card = createSampleCard(title: marketName, index: index)
            cards.append(card)
        }
        
        return cards
    }
    
    private func createSampleCard(title: String, index: Int) -> UIView {
        let container = UIView()
        container.backgroundColor = .systemGray6
        container.layer.cornerRadius = 8
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = title
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let detailLabel = UILabel()
        detailLabel.text = "Sample market content for \(marketGroupTitle)"
        detailLabel.font = .systemFont(ofSize: 14, weight: .regular)
        detailLabel.textColor = .secondaryLabel
        detailLabel.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(label)
        container.addSubview(detailLabel)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            
            detailLabel.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 4),
            detailLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            detailLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            detailLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16),
            
            container.heightAnchor.constraint(greaterThanOrEqualToConstant: 80)
        ])
        
        return container
    }
    
    private func createSpacer(height: CGFloat) -> UIView {
        let spacer = UIView()
        spacer.translatesAutoresizingMaskIntoConstraints = false
        spacer.heightAnchor.constraint(equalToConstant: height).isActive = true
        return spacer
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Scroll view
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Content view
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Main stack view
            mainStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            mainStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            mainStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            mainStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            
            // Loading indicator
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupBindings() {
        // Bind loading state
        viewModel.isLoadingPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                if isLoading {
                    self?.loadingIndicator.startAnimating()
                } else {
                    self?.loadingIndicator.stopAnimating()
                }
            }
            .store(in: &cancellables)
        
        // Bind error state
        viewModel.errorPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                if let error = error {
                    self?.showError(error)
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Helper Methods
    
    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        alert.addAction(UIAlertAction(title: "Retry", style: .default) { [weak self] _ in
            self?.viewModel.loadMarkets()
        })
        present(alert, animated: true)
    }
}
