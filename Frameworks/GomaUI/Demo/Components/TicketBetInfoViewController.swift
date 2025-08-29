import UIKit
import GomaUI
import SwiftUI

class TicketBetInfoViewController: UIViewController {
    
    // MARK: - Properties
    private var currentDisplayMode: DisplayMode = .stackView
    
    // Mock data representing different ticket states and corner styles
    private let ticketViewModels: [(title: String, viewModel: MockTicketBetInfoViewModel, cornerStyle: CornerRadiusStyle)] = [
        ("Basic Ticket", MockTicketBetInfoViewModel.pendingMock(), .all(radius: 8)),
        ("With Cashout Amount", MockTicketBetInfoViewModel.pendingMockWithCashout(), .all(radius: 8)),
        ("With Cashout Slider", MockTicketBetInfoViewModel.pendingMockWithSlider(), .all(radius: 8)),
        ("With Both Components", MockTicketBetInfoViewModel.pendingMockWithBoth(), .all(radius: 8)),
        ("Multiple Tickets", MockTicketBetInfoViewModel.multipleTicketsMock(), .topOnly(radius: 12)),
        ("Long Competition Names", MockTicketBetInfoViewModel.longCompetitionNamesMock(), .bottomOnly(radius: 16))
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
        tableView.register(TicketBetInfoTableViewCell.self, forCellReuseIdentifier: "TicketBetInfoTableViewCell")
        
        // Configure table view for proper dynamic height behavior
        tableView.rowHeight = UITableView.automaticDimension
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        tableView.estimatedSectionHeaderHeight = 44
        
        // Remove extra separators and spacing
        tableView.tableFooterView = UIView()
        tableView.sectionFooterHeight = 0
        tableView.estimatedSectionFooterHeight = 0
        
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
        
        for (title, mockViewModel, cornerStyle) in ticketViewModels {
            // Add section header
            let headerLabel = Self.createSectionHeaderLabel(title: title)
            stackView.addArrangedSubview(headerLabel)
            
            // Add ticket bet info view with container
            let containerView = UIView()
            containerView.translatesAutoresizingMaskIntoConstraints = false
            
            let ticketBetInfoView = TicketBetInfoView(viewModel: mockViewModel, cornerRadiusStyle: cornerStyle)
            ticketBetInfoView.translatesAutoresizingMaskIntoConstraints = false
            
            containerView.addSubview(ticketBetInfoView)
            
            NSLayoutConstraint.activate([
                ticketBetInfoView.topAnchor.constraint(equalTo: containerView.topAnchor),
                ticketBetInfoView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
                ticketBetInfoView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
                ticketBetInfoView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
            ])
            
            // Set up interaction callbacks for demonstration
            mockViewModel.onNavigationTap = { [weak self] in
                self?.handleNavigationTap(for: title)
            }
            mockViewModel.onRebetTap = { [weak self] in
                self?.handleRebetTap(for: title)
            }
            mockViewModel.onCashoutTap = { [weak self] in
                self?.handleCashoutTap(for: title)
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
            
            // Reload data and force proper layout
            tableView.reloadData()
            
            // Force layout pass to ensure proper height calculations on first display
            DispatchQueue.main.async { [weak self] in
                self?.tableView.layoutIfNeeded()
            }
        }
    }
    
    // MARK: - Interaction Handlers
    private func handleNavigationTap(for title: String) {
        let alert = UIAlertController(
            title: "Navigation Tapped",
            message: "Navigation action for: \(title)",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func handleRebetTap(for title: String) {
        let alert = UIAlertController(
            title: "Rebet Tapped",
            message: "Rebet action for: \(title)",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func handleCashoutTap(for title: String) {
        let alert = UIAlertController(
            title: "Cashout Tapped",
            message: "Cashout action for: \(title)",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension TicketBetInfoViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return ticketViewModels.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TicketBetInfoTableViewCell", for: indexPath) as! TicketBetInfoTableViewCell
        let (title, mockViewModel, cornerStyle) = ticketViewModels[indexPath.section]
        
        // Set up interaction callbacks for demonstration
        mockViewModel.onNavigationTap = { [weak self] in
            self?.handleNavigationTap(for: title)
        }
        mockViewModel.onRebetTap = { [weak self] in
            self?.handleRebetTap(for: title)
        }
        mockViewModel.onCashoutTap = { [weak self] in
            self?.handleCashoutTap(for: title)
        }
        
        cell.configure(with: mockViewModel, cornerStyle: cornerStyle)
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ticketViewModels[section].title
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        // Provide realistic estimated heights based on content type
        let (title, _, _) = ticketViewModels[indexPath.section]
        
        switch title {
        case "Basic Ticket":
            return 280 // Basic ticket with standard content
        case "With Cashout Amount":
            return 320 // Basic ticket + cashout amount section
        case "With Cashout Slider":
            return 380 // Basic ticket + cashout slider (taller)
        case "With Both Components":
            return 450 // Basic ticket + both cashout components
        case "Multiple Tickets":
            return 500 // Multiple tickets can be quite tall
        case "Long Competition Names":
            return 320 // Similar to basic but potentially taller due to text wrapping
        default:
            return 300 // Safe default
        }
    }
}

// MARK: - Factory Methods
extension TicketBetInfoViewController {
    
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

// MARK: - SwiftUI Preview
#if DEBUG
@available(iOS 17.0, *)
#Preview("TicketBetInfo Demo") {
    PreviewUIViewController {
        let vc = TicketBetInfoViewController()
        vc.title = "Ticket Bet Info View"
        return vc
    }
}
#endif