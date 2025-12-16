import UIKit
import GomaUI
import SwiftUI

enum DisplayMode: Int, CaseIterable {
    case stackView = 0
    case tableView = 1
    
    var title: String {
        switch self {
        case .stackView:
            return "Stack View"
        case .tableView:
            return "Table View"
        }
    }
}

class TicketSelectionViewController: UIViewController {
    
    // MARK: - Properties
    private var currentDisplayMode: DisplayMode = .stackView
    
    // Mock data representing different ticket states
    private let ticketViewModels: [(title: String, viewModel: MockTicketSelectionViewModel)] = [
        ("Premier League - PreLive", MockTicketSelectionViewModel.preLiveMock),
        ("Champions League - PreLive", MockTicketSelectionViewModel.preLiveChampionsLeagueMock),
        ("La Liga - Live Match", MockTicketSelectionViewModel.liveMock),
        ("Bundesliga - Live Draw", MockTicketSelectionViewModel.liveDrawMock),
        ("Serie A - High Score Live", MockTicketSelectionViewModel.liveHighScoreMock),
        ("Long Team Names", MockTicketSelectionViewModel.longTeamNamesMock),
        ("No Icons Example", MockTicketSelectionViewModel.noIconsMock)
    ]
    
    // MARK: - UI Components
    private lazy var modeSegmentedControl: UISegmentedControl = Self.createModeSegmentedControl()
    private lazy var scrollView: UIScrollView = Self.createScrollView()
    private lazy var stackView: UIStackView = Self.createStackView()
    private lazy var tableView: UITableView = Self.createTableView()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        self.setupActions()
        self.displayCurrentMode()
    }
    
    // MARK: - Setup
    private func setupView() {
        view.backgroundColor = .systemGroupedBackground
        
        view.addSubview(modeSegmentedControl)
        view.addSubview(scrollView)
        view.addSubview(tableView)
        
        scrollView.addSubview(stackView)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(TicketSelectionTableViewCell.self, forCellReuseIdentifier: "TicketSelectionTableViewCell")
        
        setupConstraints()
        setupStackViewContent()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Mode segmented control
            modeSegmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            modeSegmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            modeSegmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            modeSegmentedControl.heightAnchor.constraint(equalToConstant: 32),
            
            // Scroll view (for stack view mode)
            scrollView.topAnchor.constraint(equalTo: modeSegmentedControl.bottomAnchor, constant: 16),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            // Stack view inside scroll view
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Table view
            tableView.topAnchor.constraint(equalTo: modeSegmentedControl.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setupStackViewContent() {
        // Clear existing content
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for (title, mockViewModel) in ticketViewModels {
            // Add section header
            let headerLabel = Self.createSectionHeaderLabel(title: title)
            stackView.addArrangedSubview(headerLabel)
            
            // Add ticket view with container
            let containerView = UIView()
            containerView.translatesAutoresizingMaskIntoConstraints = false
            
            let ticketView = TicketSelectionView(viewModel: mockViewModel)
            ticketView.translatesAutoresizingMaskIntoConstraints = false
            
            containerView.addSubview(ticketView)
            
            NSLayoutConstraint.activate([
                ticketView.topAnchor.constraint(equalTo: containerView.topAnchor),
                ticketView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
                ticketView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
                ticketView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
            ])
            
            // Set up tap callback for demonstration
            mockViewModel.onTicketTapped = { [weak self] in
                self?.handleTicketTap(for: title)
            }
            
            stackView.addArrangedSubview(containerView)
            
            // Add spacing
            if title != ticketViewModels.last?.title {
                let spacerView = UIView()
                spacerView.translatesAutoresizingMaskIntoConstraints = false
                spacerView.heightAnchor.constraint(equalToConstant: 20).isActive = true
                stackView.addArrangedSubview(spacerView)
            }
        }
        
        // Add bottom spacing
        let bottomSpacerView = UIView()
        bottomSpacerView.translatesAutoresizingMaskIntoConstraints = false
        bottomSpacerView.heightAnchor.constraint(equalToConstant: 20).isActive = true
        stackView.addArrangedSubview(bottomSpacerView)
    }
    
    private func setupActions() {
        modeSegmentedControl.addTarget(self, action: #selector(modeChanged), for: .valueChanged)
    }
    
    // MARK: - Actions
    @objc private func modeChanged() {
        currentDisplayMode = DisplayMode(rawValue: modeSegmentedControl.selectedSegmentIndex) ?? .stackView
        displayCurrentMode()
    }
    
    private func displayCurrentMode() {
        switch currentDisplayMode {
        case .stackView:
            scrollView.isHidden = false
            tableView.isHidden = true
        case .tableView:
            scrollView.isHidden = true
            tableView.isHidden = false
            tableView.reloadData()
        }
    }
    
    private func handleTicketTap(for title: String) {
        let alert = UIAlertController(
            title: "Ticket Tapped",
            message: "You tapped on: \(title)",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension TicketSelectionViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return ticketViewModels.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TicketSelectionTableViewCell", for: indexPath) as! TicketSelectionTableViewCell
        let (_, mockViewModel) = ticketViewModels[indexPath.section]
        
        // Set up tap callback for demonstration
        mockViewModel.onTicketTapped = { [weak self] in
            let title = self?.ticketViewModels[indexPath.section].title ?? "Unknown"
            self?.handleTicketTap(for: title)
        }
        
        cell.configure(with: mockViewModel)
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ticketViewModels[section].title
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140 // Approximate height for ticket selection view
    }
}

// MARK: - Factory Methods
extension TicketSelectionViewController {
    
    private static func createModeSegmentedControl() -> UISegmentedControl {
        let items = DisplayMode.allCases.map { $0.title }
        let segmentedControl = UISegmentedControl(items: items)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.backgroundColor = .systemBackground
        return segmentedControl
    }
    
    private static func createScrollView() -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = .systemGroupedBackground
        scrollView.showsVerticalScrollIndicator = true
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }
    
    private static func createStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .fill
        stackView.distribution = .fill
        return stackView
    }
    
    private static func createTableView() -> UITableView {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .systemGroupedBackground
        tableView.separatorStyle = .none
        tableView.isHidden = true // Initially hidden
        return tableView
    }
    
    private static func createSectionHeaderLabel(title: String) -> UIView {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = title
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .secondaryLabel
        label.textAlignment = .left
        label.numberOfLines = 1
        
        // Add padding container
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            label.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            label.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -4)
        ])
        
        return containerView
    }
}


class TicketSelectionTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    private var ticketSelectionView: TicketSelectionView?
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCell()
    }
    
    // MARK: - Setup
    private func setupCell() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none
        
        // Add margins for visual separation
        contentView.layoutMargins = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
    }
    
    // MARK: - Configuration
    func configure(with viewModel: TicketSelectionViewModelProtocol) {
        // Remove existing ticket view if any
        ticketSelectionView?.removeFromSuperview()
        
        // Create new ticket view
        ticketSelectionView = TicketSelectionView(viewModel: viewModel)
        
        guard let ticketSelectionView = ticketSelectionView else { return }
        
        ticketSelectionView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(ticketSelectionView)
        
        // Setup constraints for dynamic height
        NSLayoutConstraint.activate([
            ticketSelectionView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            ticketSelectionView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            ticketSelectionView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            ticketSelectionView.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor)
        ])
    }
    
    // MARK: - Reuse
    override func prepareForReuse() {
        super.prepareForReuse()
        ticketSelectionView?.removeFromSuperview()
        ticketSelectionView = nil
    }
    
    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Ensure proper layout for dynamic height calculation
        contentView.layoutIfNeeded()
    }
    
    // MARK: - Size Calculation
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        guard let ticketSelectionView = ticketSelectionView else {
            return CGSize(width: size.width, height: 140) // Default height
        }
        
        // Calculate the size needed by the ticket selection view
        let margins = contentView.layoutMargins
        let availableWidth = size.width - margins.left - margins.right
        let availableSize = CGSize(width: availableWidth, height: CGFloat.greatestFiniteMagnitude)
        
        let ticketSize = ticketSelectionView.sizeThatFits(availableSize)
        let totalHeight = ticketSize.height + margins.top + margins.bottom
        
        return CGSize(width: size.width, height: totalHeight)
    }
}


// MARK: - SwiftUI Preview
#if DEBUG
@available(iOS 17.0, *)
#Preview("TicketSelection Demo") {
    PreviewUIViewController {
        let vc = TicketSelectionViewController()
        vc.title = "Ticket Selection View"
        return vc
    }
}
#endif
