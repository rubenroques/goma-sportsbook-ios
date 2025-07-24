//
//  PreviewTableViewController.swift
//  Sportsbook
//
//  Created by
//

import UIKit
import SwiftUI

/// A generic protocol for preview state items
public protocol PreviewStateRepresentable {
    /// The title displayed in the section header
    var title: String { get }

    /// Optional subtitle for more context
    var subtitle: String? { get }

    /// Optional height for this specific state's cell
    var cellHeight: CGFloat? { get }
}

/// Default implementation of subtitle and cellHeight as optional
public extension PreviewStateRepresentable {
    var subtitle: String? { return nil }
    var cellHeight: CGFloat? { return nil }
}

/// A generic UITableViewController for use in SwiftUI previews
@available(iOS 17.0, *)
public class PreviewTableViewController<Cell: UITableViewCell, State: PreviewStateRepresentable>: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // MARK: - Properties

    /// Table view for displaying cells
    private let tableView = UITableView(frame: .zero, style: .grouped)

    /// Cell configurator closure
    public typealias CellConfigurator = (Cell, State, IndexPath) -> Void

    /// The states to display in the table
    private let states: [State]

    /// Closure for configuring cells
    private let configurator: CellConfigurator

    /// Cell reuse identifier
    private let cellReuseIdentifier: String

    /// Whether to register the cell class
    private let registerCellClass: Bool

    /// Default height for cells
    private let defaultCellHeight: CGFloat

    /// Whether to use estimated height for cells
    private let useEstimatedHeight: Bool

    // MARK: - Initialization

    /// Initialize with states and a cell configurator
    /// - Parameters:
    ///   - states: The preview states to display
    ///   - cellClass: The cell class to register (optional)
    ///   - cellReuseIdentifier: Custom reuse identifier (defaults to cell class name)
    ///   - defaultCellHeight: Default height for cells (defaults to automatic)
    ///   - useEstimatedHeight: Whether to use estimated row heights (defaults to true)
    ///   - configurator: Closure to configure each cell
    public init(
        states: [State],
        cellClass: Cell.Type? = nil,
        cellReuseIdentifier: String? = nil,
        defaultCellHeight: CGFloat = UITableView.automaticDimension,
        useEstimatedHeight: Bool = true,
        configurator: @escaping CellConfigurator
    ) {
        self.states = states
        self.configurator = configurator
        self.registerCellClass = cellClass != nil
        self.cellReuseIdentifier = cellReuseIdentifier ?? String(describing: Cell.self)
        self.defaultCellHeight = defaultCellHeight
        self.useEstimatedHeight = useEstimatedHeight

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override public func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupTableView()
    }

    // MARK: - Setup

    private func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        if registerCellClass {
            tableView.register(Cell.self, forCellReuseIdentifier: cellReuseIdentifier)
        }
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "DefaultCell")

        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .systemGroupedBackground

        if useEstimatedHeight {
            tableView.estimatedRowHeight = 200
            tableView.rowHeight = UITableView.automaticDimension
        } else {
            tableView.rowHeight = defaultCellHeight
        }
    }

    public func numberOfSections(in tableView: UITableView) -> Int {
        return states.count
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // If we're not using cell registration, we create a basic container cell
        guard registerCellClass else {
            let containerCell = tableView.dequeueReusableCell(withIdentifier: "DefaultCell", for: indexPath)
            containerCell.selectionStyle = .none
            containerCell.backgroundColor = .clear

            // Clear existing subviews to avoid duplicates
            for subview in containerCell.contentView.subviews {
                subview.removeFromSuperview()
            }

            // Create our custom cell manually
            let customCell = Cell(frame: .zero)

            // Configure the cell using the provided closure
            configurator(customCell, states[indexPath.section], indexPath)

            // Add it to the content view with margins
            containerCell.contentView.addSubview(customCell)
            customCell.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                customCell.topAnchor.constraint(equalTo: containerCell.contentView.topAnchor, constant: 8),
                customCell.leadingAnchor.constraint(equalTo: containerCell.contentView.leadingAnchor, constant: 16),
                customCell.trailingAnchor.constraint(equalTo: containerCell.contentView.trailingAnchor, constant: -16),
                customCell.bottomAnchor.constraint(equalTo: containerCell.contentView.bottomAnchor, constant: -8)
            ])

            return containerCell
        }

        // If we are using cell registration, dequeue and configure directly
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as? Cell else {
            return UITableViewCell()
        }

        configurator(cell, states[indexPath.section], indexPath)
        return cell
    }

    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .systemGroupedBackground

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 4

        let titleLabel = UILabel()
        titleLabel.text = states[section].title
        titleLabel.font = .boldSystemFont(ofSize: 16)
        titleLabel.textColor = .label
        stackView.addArrangedSubview(titleLabel)

        // Add subtitle if present
        if let subtitle = states[section].subtitle {
            let subtitleLabel = UILabel()
            subtitleLabel.text = subtitle
            subtitleLabel.font = .systemFont(ofSize: 12)
            subtitleLabel.textColor = .secondaryLabel
            stackView.addArrangedSubview(subtitleLabel)
        }

        headerView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: headerView.trailingAnchor, constant: -16),
            stackView.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 8),
            stackView.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -8)
        ])

        return headerView
    }

    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return states[section].subtitle != nil ? 60 : 44
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // Use state-specific height if available
        if let cellHeight = states[indexPath.section].cellHeight {
            return cellHeight
        }
        return defaultCellHeight
    }
}

//
// MARK: - Space Mission Preview - Usage Example
// In the next lines you will find an example of how to use the PreviewTableViewController
// This is a simple example, but you can use it to create more complex previews
/// Represents a space mission item in the preview

/// Represents a space mission in the preview
struct SpaceMissionState: PreviewStateRepresentable {
    let title: String
    let subtitle: String?
    let missionPatchName: String
    let cellHeight: CGFloat?

    init(title: String, subtitle: String? = nil, missionPatchName: String, cellHeight: CGFloat? = 80) {
        self.title = title
        self.subtitle = subtitle
        self.missionPatchName = missionPatchName
        self.cellHeight = cellHeight
    }
}

class SpaceMissionCell: UITableViewCell {
    private let missionPatchView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        selectionStyle = .none
        backgroundColor = .systemBackground

        // Setup Image
        missionPatchView.contentMode = .scaleAspectFit
        missionPatchView.layer.cornerRadius = 10
        missionPatchView.clipsToBounds = true
        contentView.addSubview(missionPatchView)
        missionPatchView.translatesAutoresizingMaskIntoConstraints = false

        // Setup Title Label
        titleLabel.font = .boldSystemFont(ofSize: 16)
        titleLabel.textAlignment = .left
        contentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        // Setup Subtitle Label
        subtitleLabel.font = .systemFont(ofSize: 14)
        subtitleLabel.textAlignment = .left
        subtitleLabel.textColor = .gray
        contentView.addSubview(subtitleLabel)
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            missionPatchView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            missionPatchView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            missionPatchView.widthAnchor.constraint(equalToConstant: 50),
            missionPatchView.heightAnchor.constraint(equalToConstant: 50),

            titleLabel.leadingAnchor.constraint(equalTo: missionPatchView.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),

            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }

    func configure(with state: SpaceMissionState) {
        titleLabel.text = state.title
        subtitleLabel.text = state.subtitle
        missionPatchView.image = UIImage(systemName: state.missionPatchName)
    }
}

@available(iOS 17.0, *)
#Preview("Space Missions Usage Example") {
    PreviewUIViewController {
        PreviewTableViewController(
            states: [
                SpaceMissionState(title: "Apollo 11", subtitle: "First moon landing, 1969", missionPatchName: "moon.fill"),
                SpaceMissionState(title: "Voyager 1", subtitle: "Farthest human-made object", missionPatchName: "arrow.up.right.circle.fill"),
                SpaceMissionState(title: "Hubble Telescope", subtitle: "Exploring deep space", missionPatchName: "sparkles"),
                SpaceMissionState(title: "Mars Rover Perseverance", subtitle: "Searching for life on Mars", missionPatchName: "ant.fill"),
                SpaceMissionState(title: "James Webb Telescope", subtitle: "Next-gen space telescope", missionPatchName: "star.fill")
            ],
            cellClass: SpaceMissionCell.self,
            defaultCellHeight: 80
        ) { cell, state, _ in
            cell.configure(with: state)
        }
    }
}
