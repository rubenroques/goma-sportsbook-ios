//
//  MarketsTabSimpleViewController.swift
//  Sportsbook
//
//  Created on 2025-07-16.
//

import UIKit
import Combine
import GomaUI

class MarketsTabSimpleViewController: UIViewController {
    
    // MARK: - Properties

    private let viewModel: MarketsTabSimpleViewModel
    private var cancellables = Set<AnyCancellable>()

    // BLINK_DEBUG: Track previous data for comparison
    private var previousMarketGroups: [MarketGroupWithIcons] = []
    private var reloadCounter = 0
    
    // MARK: - Computed Properties
    
    public var marketGroupId: String { viewModel.marketGroupId }
    public var marketGroupTitle: String { viewModel.marketGroupTitle }
    
    // MARK: - UI Components

    private let tableView: UITableView
    private let loadingIndicator = UIActivityIndicatorView(style: .medium)
    
    // MARK: - Initialization
    
    init(viewModel: MarketsTabSimpleViewModel) {
        self.viewModel = viewModel

        // Create table view
        tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false

        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Deinit
    
    deinit {
        cancellables.removeAll()
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupConstraints()
        setupBindings()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = UIColor.App.backgroundPrimary

        // Configure table view
        tableView.backgroundColor = UIColor.App.backgroundPrimary
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = true
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 150
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.sectionHeaderTopPadding = 0
        tableView.contentInsetAdjustmentBehavior = .never
        
        // Register cell
        tableView.register(
            MarketTypeGroupTableViewCell.self,
            forCellReuseIdentifier: MarketTypeGroupTableViewCell.reuseIdentifier
        )

        // Configure loading indicator
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.hidesWhenStopped = true

        // Add views to hierarchy
        view.addSubview(tableView)
        view.addSubview(loadingIndicator)
    }
    
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Table view
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

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
                guard let self = self else { return }
                if isLoading {
                    self.loadingIndicator.startAnimating()
                } else {
                    self.loadingIndicator.stopAnimating()
                }
            }
            .store(in: &cancellables)
        
        // Bind error state
        viewModel.errorPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                guard let self = self else { return }
                if let error = error {
                    self.showError(error)
                }
            }
            .store(in: &cancellables)
        
        // Bind market groups data
        viewModel.marketGroupsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newMarketGroups in
                guard let self = self else { return }

                self.reloadCounter += 1
                let dataChanged = self.previousMarketGroups != newMarketGroups

                print("BLINK_DEBUG [MarketsTabVC] 📊 Reload #\(self.reloadCounter) for '\(self.marketGroupTitle)' | Data changed: \(dataChanged) | Groups count: \(newMarketGroups.count)")

                if dataChanged {
                    print("BLINK_DEBUG [MarketsTabVC] ✏️  Data CHANGED - Markets: \(newMarketGroups.map { $0.groupName }.joined(separator: ", "))")
                } else {
                    print("BLINK_DEBUG [MarketsTabVC] ⚠️  Data UNCHANGED but reload triggered!")
                }

                self.previousMarketGroups = newMarketGroups
                self.tableView.reloadData()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Helper Methods

    private func showError(_ message: String) {
        let alert = UIAlertController(title: localized("error"), message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: localized("ok"), style: .default))
        alert.addAction(UIAlertAction(title: localized("retry"), style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.viewModel.loadMarkets()
        })
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension MarketsTabSimpleViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.currentMarketGroups.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: MarketTypeGroupTableViewCell.reuseIdentifier,
            for: indexPath
        ) as? MarketTypeGroupTableViewCell else {
            return UITableViewCell()
        }

        let marketGroupWithIcons = viewModel.currentMarketGroups[indexPath.row]

        // Configure cell
        cell.configure(with: marketGroupWithIcons)

        // Set up outcome selection callbacks
        cell.onOutcomeSelected = { [weak self] lineId, outcomeType in
            guard let self = self else { return }
            self.viewModel.handleOutcomeSelection(
                marketGroupId: marketGroupWithIcons.marketGroup.id,
                lineId: lineId,
                outcomeType: outcomeType,
                isSelected: true
            )
        }

        cell.onOutcomeDeselected = { [weak self] lineId, outcomeType in
            guard let self = self else { return }
            self.viewModel.handleOutcomeSelection(
                marketGroupId: marketGroupWithIcons.marketGroup.id,
                lineId: lineId,
                outcomeType: outcomeType,
                isSelected: false
            )
        }

        return cell
    }
}

// MARK: - UITableViewDelegate
extension MarketsTabSimpleViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // Empty header view for top spacing
        let headerView = UIView()
        headerView.backgroundColor = .clear
        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 16 // Top spacing (matches UICollectionView contentInsets.top)
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        // Empty footer view for bottom spacing
        let footerView = UIView()
        footerView.backgroundColor = .clear
        return footerView
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 16 // Bottom spacing (matches UICollectionView contentInsets.bottom)
    }
}
