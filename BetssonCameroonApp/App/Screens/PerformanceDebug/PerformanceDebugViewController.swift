//
//  PerformanceDebugViewController.swift
//  BetssonCameroonApp
//
//  Hidden debug screen for viewing performance metrics
//  Accessible via 6 taps on Betsson logo
//

import UIKit
import GomaPerformanceKit

class PerformanceDebugViewController: UIViewController {

    // MARK: - Data Management

    private enum FilterMode {
        case all
        case feature(PerformanceFeature)
        case layer(PerformanceLayer)
        case errorsOnly
    }

    private var allEntries: [PerformanceEntry] = []
    private var filteredEntries: [PerformanceEntry] = []
    private var currentFilter: FilterMode = .all

    // Grouped by feature for sectioned display
    private var groupedEntries: [(feature: PerformanceFeature, entries: [PerformanceEntry])] = []

    // MARK: - UI Components

    private lazy var toolbar: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        return view
    }()

    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        button.tintColor = .label
        button.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        return button
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Performance Logs"
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textAlignment = .center
        return label
    }()

    private lazy var filterButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "line.3.horizontal.decrease.circle"), for: .normal)
        button.tintColor = .label
        button.addTarget(self, action: #selector(filterTapped), for: .touchUpInside)
        return button
    }()

    private lazy var copyButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "doc.on.doc"), for: .normal)
        button.tintColor = .label
        button.addTarget(self, action: #selector(copyTapped), for: .touchUpInside)
        return button
    }()

    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.delegate = self
        table.dataSource = self
        table.register(PerformanceEntryCell.self, forCellReuseIdentifier: "PerformanceEntryCell")
        table.refreshControl = refreshControl
        return table
    }()

    private lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        return control
    }()

    private lazy var emptyStateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "No performance data yet.\nUse the app and come back."
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadData()
    }

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = .systemGroupedBackground

        view.addSubview(toolbar)
        toolbar.addSubview(closeButton)
        toolbar.addSubview(titleLabel)
        toolbar.addSubview(filterButton)
        toolbar.addSubview(copyButton)

        view.addSubview(tableView)
        view.addSubview(emptyStateLabel)

        NSLayoutConstraint.activate([
            // Toolbar
            toolbar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            toolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            toolbar.heightAnchor.constraint(equalToConstant: 50),

            // Close button
            closeButton.leadingAnchor.constraint(equalTo: toolbar.leadingAnchor, constant: 16),
            closeButton.centerYAnchor.constraint(equalTo: toolbar.centerYAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: 30),
            closeButton.heightAnchor.constraint(equalToConstant: 30),

            // Title
            titleLabel.centerXAnchor.constraint(equalTo: toolbar.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: toolbar.centerYAnchor),

            // Copy button
            copyButton.trailingAnchor.constraint(equalTo: toolbar.trailingAnchor, constant: -16),
            copyButton.centerYAnchor.constraint(equalTo: toolbar.centerYAnchor),
            copyButton.widthAnchor.constraint(equalToConstant: 30),
            copyButton.heightAnchor.constraint(equalToConstant: 30),

            // Filter button
            filterButton.trailingAnchor.constraint(equalTo: copyButton.leadingAnchor, constant: -12),
            filterButton.centerYAnchor.constraint(equalTo: toolbar.centerYAnchor),
            filterButton.widthAnchor.constraint(equalToConstant: 30),
            filterButton.heightAnchor.constraint(equalToConstant: 30),

            // TableView
            tableView.topAnchor.constraint(equalTo: toolbar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // Empty state
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            emptyStateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32)
        ])
    }

    // MARK: - Data Loading

    private func loadData() {
        allEntries = PerformanceTracker.shared.getAllLogs()
        applyFilter()
    }

    @objc private func refreshData() {
        loadData()
        refreshControl.endRefreshing()
    }

    private func applyFilter() {
        switch currentFilter {
        case .all:
            filteredEntries = allEntries
        case .feature(let feature):
            filteredEntries = allEntries.filter { $0.feature == feature }
        case .layer(let layer):
            filteredEntries = allEntries.filter { $0.layer == layer }
        case .errorsOnly:
            filteredEntries = allEntries.filter { entry in
                entry.metadata["status"]?.lowercased().contains("error") == true
            }
        }

        // Group by feature and sort by start time
        let grouped = Dictionary(grouping: filteredEntries) { $0.feature }
        groupedEntries = grouped.map { (feature: $0.key, entries: $0.value.sorted { $0.startTime > $1.startTime }) }
            .sorted { $0.feature.rawValue < $1.feature.rawValue }

        emptyStateLabel.isHidden = !filteredEntries.isEmpty
        tableView.reloadData()
    }

    // MARK: - Actions

    @objc private func closeTapped() {
        dismiss(animated: true)
    }

    @objc private func filterTapped() {
        let alert = UIAlertController(title: "Filter Logs", message: nil, preferredStyle: .actionSheet)

        // Show All
        alert.addAction(UIAlertAction(title: "Show All", style: .default) { [weak self] _ in
            self?.currentFilter = .all
            self?.applyFilter()
        })

        // Filter by Feature
        alert.addAction(UIAlertAction(title: "Filter by Feature", style: .default) { [weak self] _ in
            self?.showFeatureFilter()
        })

        // Filter by Layer
        alert.addAction(UIAlertAction(title: "Filter by Layer", style: .default) { [weak self] _ in
            self?.showLayerFilter()
        })

        // Show Only Errors
        alert.addAction(UIAlertAction(title: "Show Only Errors", style: .default) { [weak self] _ in
            self?.currentFilter = .errorsOnly
            self?.applyFilter()
        })

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        present(alert, animated: true)
    }

    private func showFeatureFilter() {
        let alert = UIAlertController(title: "Select Feature", message: nil, preferredStyle: .actionSheet)

        for feature in PerformanceFeature.allCases {
            alert.addAction(UIAlertAction(title: feature.rawValue.capitalized, style: .default) { [weak self] _ in
                self?.currentFilter = .feature(feature)
                self?.applyFilter()
            })
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    private func showLayerFilter() {
        let alert = UIAlertController(title: "Select Layer", message: nil, preferredStyle: .actionSheet)

        for layer in PerformanceLayer.allCases {
            alert.addAction(UIAlertAction(title: layer.rawValue.uppercased(), style: .default) { [weak self] _ in
                self?.currentFilter = .layer(layer)
                self?.applyFilter()
            })
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    @objc private func copyTapped() {
        let csv = generateCSV()
        UIPasteboard.general.string = csv

        // Show confirmation
        let alert = UIAlertController(title: "Copied!", message: "\(filteredEntries.count) entries copied to clipboard as CSV", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // MARK: - CSV Generation

    private func generateCSV() -> String {
        var csv = "Feature,Layer,Duration,StartTime,EndTime,Metadata\n"

        for entry in filteredEntries {
            let duration = String(format: "%.3f", entry.duration)
            let metadataString = entry.metadata.map { "\($0.key)=\($0.value)" }.joined(separator: "; ")

            let row = "\(entry.feature.rawValue),\(entry.layer.rawValue),\(duration),\(entry.startTime),\(entry.endTime),\"\(metadataString)\"\n"
            csv += row
        }

        return csv
    }
}

// MARK: - UITableViewDataSource

extension PerformanceDebugViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return groupedEntries.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupedEntries[section].entries.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PerformanceEntryCell", for: indexPath) as! PerformanceEntryCell
        let entry = groupedEntries[indexPath.section].entries[indexPath.row]
        cell.configure(with: entry)
        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let group = groupedEntries[section]
        let count = group.entries.count
        let avgDuration = group.entries.map { $0.duration }.reduce(0, +) / Double(count)

        return "\(group.feature.rawValue.uppercased()) (\(count) entries, avg \(String(format: "%.3f", avgDuration))s)"
    }
}

// MARK: - UITableViewDelegate

extension PerformanceDebugViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let entry = groupedEntries[indexPath.section].entries[indexPath.row]
        showDetailAlert(for: entry)
    }

    private func showDetailAlert(for entry: PerformanceEntry) {
        let duration = String(format: "%.3f", entry.duration)
        let metadataString = entry.metadata.isEmpty ? "None" : entry.metadata.map { "\($0.key): \($0.value)" }.joined(separator: "\n")

        let message = """
        Feature: \(entry.feature.rawValue)
        Layer: \(entry.layer.rawValue)
        Duration: \(duration)s
        Start: \(entry.startTime)
        End: \(entry.endTime)

        Metadata:
        \(metadataString)
        """

        let alert = UIAlertController(title: "Entry Details", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - Performance Entry Cell

private class PerformanceEntryCell: UITableViewCell {

    private let layerBadge: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 11, weight: .semibold)
        label.textColor = .white
        label.textAlignment = .center
        label.backgroundColor = .systemBlue
        label.layer.cornerRadius = 4
        label.clipsToBounds = true
        return label
    }()

    private let durationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textAlignment = .right
        return label
    }()

    private let timestampLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12)
        label.textColor = .secondaryLabel
        return label
    }()

    private let metadataLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 11)
        label.textColor = .tertiaryLabel
        label.numberOfLines = 2
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.addSubview(layerBadge)
        contentView.addSubview(durationLabel)
        contentView.addSubview(timestampLabel)
        contentView.addSubview(metadataLabel)

        NSLayoutConstraint.activate([
            // Layer badge
            layerBadge.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            layerBadge.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            layerBadge.widthAnchor.constraint(equalToConstant: 40),
            layerBadge.heightAnchor.constraint(equalToConstant: 20),

            // Duration label
            durationLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            durationLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),

            // Timestamp
            timestampLabel.leadingAnchor.constraint(equalTo: layerBadge.trailingAnchor, constant: 8),
            timestampLabel.topAnchor.constraint(equalTo: layerBadge.bottomAnchor, constant: 4),
            timestampLabel.trailingAnchor.constraint(lessThanOrEqualTo: durationLabel.leadingAnchor, constant: -8),

            // Metadata
            metadataLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            metadataLabel.topAnchor.constraint(equalTo: timestampLabel.bottomAnchor, constant: 4),
            metadataLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            metadataLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }

    func configure(with entry: PerformanceEntry) {
        layerBadge.text = entry.layer.rawValue.uppercased()
        durationLabel.text = String(format: "%.3fs", entry.duration)

        // Format timestamp
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        timestampLabel.text = formatter.string(from: entry.startTime)

        // Format metadata
        if entry.metadata.isEmpty {
            metadataLabel.text = "No metadata"
        } else {
            let metadataString = entry.metadata.map { "\($0.key): \($0.value)" }.joined(separator: ", ")
            metadataLabel.text = metadataString
        }

        // Color duration based on performance
        if entry.duration > 3.0 {
            durationLabel.textColor = .systemRed
        } else if entry.duration > 1.0 {
            durationLabel.textColor = .systemOrange
        } else {
            durationLabel.textColor = .systemGreen
        }

        // Color badge based on layer
        switch entry.layer {
        case .app:
            layerBadge.backgroundColor = .systemPurple
        case .api:
            layerBadge.backgroundColor = .systemBlue
        case .web:
            layerBadge.backgroundColor = .systemGreen
        case .parsing:
            layerBadge.backgroundColor = .systemOrange
        }

        // Color feature badge based on feature (optional future enhancement)
        // Could add a second badge showing feature color
    }
}
