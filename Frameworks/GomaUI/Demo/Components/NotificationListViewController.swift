import UIKit
import GomaUI

class NotificationListViewController: UIViewController {
    
    // MARK: - Private Properties
    private lazy var scrollView: UIScrollView = Self.createScrollView()
    private lazy var contentView: UIView = Self.createContentView()
    private lazy var headerLabel: UILabel = Self.createHeaderLabel()
    private lazy var defaultNotificationListView: NotificationListView = {
        return NotificationListView(viewModel: MockNotificationListViewModel.defaultMock)
    }()
    private lazy var mixedNotificationListView: NotificationListView = {
        return NotificationListView(viewModel: MockNotificationListViewModel.mixedNotificationsMock)
    }()
    private lazy var emptyNotificationListView: NotificationListView = {
        return NotificationListView(viewModel: MockNotificationListViewModel.emptyMock)
    }()
    private lazy var unreadOnlyNotificationListView: NotificationListView = {
        return NotificationListView(viewModel: MockNotificationListViewModel.unreadOnlyMock)
    }()
    
    private lazy var sectionLabels: [UILabel] = [
        Self.createSectionLabel(text: "Default Notifications"),
        Self.createSectionLabel(text: "Mixed Notifications"),
        Self.createSectionLabel(text: "Empty State"),
        Self.createSectionLabel(text: "Unread Only")
    ]
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        applyStyles()
    }
    
    // MARK: - Setup
    private func setupView() {
        title = "Notification List"
        setupSubviews()
    }
    
    private func setupSubviews() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(headerLabel)
        
        // Add section labels and notification views
        contentView.addSubview(sectionLabels[0])
        contentView.addSubview(defaultNotificationListView)
        
        contentView.addSubview(sectionLabels[1])
        contentView.addSubview(mixedNotificationListView)
        
        contentView.addSubview(sectionLabels[2])
        contentView.addSubview(emptyNotificationListView)
        
        contentView.addSubview(sectionLabels[3])
        contentView.addSubview(unreadOnlyNotificationListView)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // ScrollView
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            // ContentView
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Header Label
            headerLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            headerLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            headerLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            
            // Section 1: Default
            sectionLabels[0].leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            sectionLabels[0].trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            sectionLabels[0].topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 30),
            
            defaultNotificationListView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            defaultNotificationListView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            defaultNotificationListView.topAnchor.constraint(equalTo: sectionLabels[0].bottomAnchor, constant: 12),
            defaultNotificationListView.heightAnchor.constraint(equalToConstant: 400),
            
            // Section 2: Mixed
            sectionLabels[1].leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            sectionLabels[1].trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            sectionLabels[1].topAnchor.constraint(equalTo: defaultNotificationListView.bottomAnchor, constant: 40),
            
            mixedNotificationListView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            mixedNotificationListView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            mixedNotificationListView.topAnchor.constraint(equalTo: sectionLabels[1].bottomAnchor, constant: 12),
            mixedNotificationListView.heightAnchor.constraint(equalToConstant: 400),
            
            // Section 3: Empty
            sectionLabels[2].leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            sectionLabels[2].trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            sectionLabels[2].topAnchor.constraint(equalTo: mixedNotificationListView.bottomAnchor, constant: 40),
            
            emptyNotificationListView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            emptyNotificationListView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            emptyNotificationListView.topAnchor.constraint(equalTo: sectionLabels[2].bottomAnchor, constant: 12),
            emptyNotificationListView.heightAnchor.constraint(equalToConstant: 200),
            
            // Section 4: Unread Only
            sectionLabels[3].leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            sectionLabels[3].trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            sectionLabels[3].topAnchor.constraint(equalTo: emptyNotificationListView.bottomAnchor, constant: 40),
            
            unreadOnlyNotificationListView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            unreadOnlyNotificationListView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            unreadOnlyNotificationListView.topAnchor.constraint(equalTo: sectionLabels[3].bottomAnchor, constant: 12),
            unreadOnlyNotificationListView.heightAnchor.constraint(equalToConstant: 250),
            unreadOnlyNotificationListView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
        ])
    }
    
    private func setupViewModel() {
        // Setup callbacks for demonstration
        if let defaultMock = defaultNotificationListView.viewModel as? MockNotificationListViewModel {
            defaultMock.onActionPerformed = { notification in
                self.showActionAlert(for: notification, section: "Default")
            }
            defaultMock.onNotificationRead = { notification in
                print("Default section: Notification marked as read - \(notification.title)")
            }
        }
        
        if let mixedMock = mixedNotificationListView.viewModel as? MockNotificationListViewModel {
            mixedMock.onActionPerformed = { notification in
                self.showActionAlert(for: notification, section: "Mixed")
            }
        }
        
        if let unreadMock = unreadOnlyNotificationListView.viewModel as? MockNotificationListViewModel {
            unreadMock.onActionPerformed = { notification in
                self.showActionAlert(for: notification, section: "Unread Only")
            }
        }
    }
    
    private func applyStyles() {
        view.backgroundColor = StyleProvider.Color.backgroundSecondary
        
        headerLabel.textColor = StyleProvider.Color.textPrimary
        sectionLabels.forEach { label in
            label.textColor = StyleProvider.Color.textPrimary
        }
    }
    
    // MARK: - Demo Actions
    private func showActionAlert(for notification: NotificationData, section: String) {
        let actionTitle = notification.action?.title ?? "Unknown Action"
        
        let alert = UIAlertController(
            title: "Action Performed",
            message: "Section: \(section)\nNotification: \(notification.title)\nAction: \(actionTitle)",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - Static Factory Methods
extension NotificationListViewController {
    
    private static func createScrollView() -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }
    
    private static func createContentView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createHeaderLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "NotificationListView Component Demo"
        label.font = StyleProvider.fontWith(type: .bold, size: 24)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }
    
    private static func createSectionLabel(text: String) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = text
        label.font = StyleProvider.fontWith(type: .semibold, size: 18)
        label.numberOfLines = 1
        return label
    }
}