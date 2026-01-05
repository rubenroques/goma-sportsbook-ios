import Foundation
import UIKit
import Combine
import SwiftUI

/// A view that displays a list of notifications using UICollectionView with NotificationCardViews
final public class NotificationListView: UIView {
    
    // MARK: - Private Properties
    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var collectionView: UICollectionView = Self.createCollectionView()
    private lazy var emptyStateLabel: UILabel = Self.createEmptyStateLabel()
    private lazy var loadingIndicator: UIActivityIndicatorView = Self.createLoadingIndicator()
    
    private var cancellables = Set<AnyCancellable>()
    private var notifications: [NotificationData] = []
    
    // MARK: - Public Properties
    public let viewModel: NotificationListViewModelProtocol
    
    // MARK: - Initialization
    public init(viewModel: NotificationListViewModelProtocol) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupView()
        setupBindings()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupView() {
        setupSubviews()
        setupCollectionView()
        applyStyles()
    }
    
    private func setupSubviews() {
        addSubview(containerView)
        containerView.addSubview(collectionView)
        containerView.addSubview(emptyStateLabel)
        containerView.addSubview(loadingIndicator)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Container View
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // Collection View
            collectionView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: containerView.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            // Empty State Label
            emptyStateLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            emptyStateLabel.leadingAnchor.constraint(greaterThanOrEqualTo: containerView.leadingAnchor, constant: 32),
            emptyStateLabel.trailingAnchor.constraint(lessThanOrEqualTo: containerView.trailingAnchor, constant: -32),
            
            // Loading Indicator
            loadingIndicator.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])
    }
    
    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        
        // Register cell
        collectionView.register(
            NotificationCardCollectionViewCell.self,
            forCellWithReuseIdentifier: NotificationCardCollectionViewCell.reuseIdentifier
        )
    }
    
    private func setupBindings() {
        viewModel.notificationListStatePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.updateUI(for: state)
            }
            .store(in: &cancellables)
    }
    
    private func applyStyles() {
        backgroundColor = .clear
        containerView.backgroundColor = .clear
        emptyStateLabel.textColor = StyleProvider.Color.textSecondary
        loadingIndicator.color = StyleProvider.Color.highlightPrimary
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        // Container no longer needs corner radius - individual cards handle their own
    }
    
    // MARK: - UI Updates
    private func updateUI(for state: NotificationListState) {
        switch state {
        case .loading:
            showLoading()
        case .loaded(let notifications):
            showNotifications(notifications)
        case .empty:
            showEmptyState()
        case .error(let error):
            showError(error)
        }
    }
    
    private func showLoading() {
        collectionView.isHidden = true
        emptyStateLabel.isHidden = true
        loadingIndicator.isHidden = false
        loadingIndicator.startAnimating()
    }
    
    private func showNotifications(_ notifications: [NotificationData]) {
        loadingIndicator.stopAnimating()
        loadingIndicator.isHidden = true
        emptyStateLabel.isHidden = true
        collectionView.isHidden = false
        
        updateNotifications(notifications)
    }
    
    private func showEmptyState() {
        loadingIndicator.stopAnimating()
        loadingIndicator.isHidden = true
        collectionView.isHidden = true
        emptyStateLabel.isHidden = false
        emptyStateLabel.text = LocalizationProvider.string("no_notifications")
    }

    private func showError(_ error: Error) {
        loadingIndicator.stopAnimating()
        loadingIndicator.isHidden = true
        collectionView.isHidden = true
        emptyStateLabel.isHidden = false
        emptyStateLabel.text = LocalizationProvider.string("failed_to_load_notifications")
    }
    
    private func updateNotifications(_ newNotifications: [NotificationData]) {
        let oldNotifications = self.notifications
        self.notifications = newNotifications
        
        // Animate changes if needed
        if oldNotifications.isEmpty {
            collectionView.reloadData()
        } else {
            // For more complex animations, you could use performBatchUpdates
            collectionView.reloadData()
        }
    }
    
    // MARK: - Public Methods
    public func refresh() {
        viewModel.refresh()
    }
    
    public func markAsRead(notificationId: String) {
        viewModel.markAsRead(notificationId: notificationId)
    }
}

// MARK: - UICollectionViewDataSource
extension NotificationListView: UICollectionViewDataSource {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return notifications.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: NotificationCardCollectionViewCell.reuseIdentifier,
            for: indexPath
        ) as? NotificationCardCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let notification = notifications[indexPath.item]
        let position = calculateCardPosition(for: indexPath.item, totalCount: notifications.count)
        
        cell.configure(with: notification, position: position) { [weak self] notification in
            self?.viewModel.performAction(for: notification)
        }
        
        return cell
    }
    
    private func calculateCardPosition(for index: Int, totalCount: Int) -> CardPosition {
        if totalCount == 1 {
            return .single
        } else if index == 0 {
            return .first
        } else if index == totalCount - 1 {
            return .last
        } else {
            return .middle
        }
    }
}

// MARK: - UICollectionViewDelegate
extension NotificationListView: UICollectionViewDelegate {
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        // Optional: Mark as read on tap
        let notification = notifications[indexPath.item]
        if notification.isUnread {
            markAsRead(notificationId: notification.id)
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension NotificationListView: UICollectionViewDelegateFlowLayout {
    
    public func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let notification = notifications[indexPath.item]
        
        // Calculate height based on content
        let width = collectionView.bounds.width - 16 // Account for insets
        let estimatedHeight = calculateHeightForNotification(notification, width: width)
        
        return CGSize(width: width, height: estimatedHeight)
    }
    
    public func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 0 // No space between cards - they should touch each other
    }
    
    public func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        return UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8) // Container padding
    }
    
    private func calculateHeightForNotification(_ notification: NotificationData, width: CGFloat) -> CGFloat {
        // Base height for padding and header
        var height: CGFloat = 16 + 16 + 16 // top + header + bottom padding
        
        // Header height (timestamp + indicator)
        height += 16
        
        // Title height - using font metrics
        let titleFont = StyleProvider.fontWith(type: .bold, size: 14)
        let titleHeight = notification.title.boundingRect(
            with: CGSize(width: width - 32, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [.font: titleFont],
            context: nil
        ).height
        height += max(titleHeight, 24) // Minimum 24pt for title
        
        // Gap between title and description
        height += 3
        
        // Description height
        let descriptionFont = StyleProvider.fontWith(type: .regular, size: 12)
        let descriptionHeight = notification.description.boundingRect(
            with: CGSize(width: width - 32, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [.font: descriptionFont],
            context: nil
        ).height
        height += max(descriptionHeight, 16) // Minimum 16pt for description
        
        // Action button if present
        if notification.hasAction {
            height += 12 + 33 // gap + button height
        }
        
        return ceil(height)
    }
}

// MARK: - Static Factory Methods
extension NotificationListView {
    
    private static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.masksToBounds = true
        return view
    }
    
    private static func createCollectionView() -> UICollectionView {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 0
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceVertical = true
        
        return collectionView
    }
    
    private static func createEmptyStateLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .medium, size: 16)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }
    
    private static func createLoadingIndicator() -> UIActivityIndicatorView {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }
}

// MARK: - SwiftUI Preview Support
#if DEBUG
@available(iOS 17.0, *)
#Preview("Default State") {
    PreviewUIViewController {
        let vc = UIViewController()
        let viewModel = MockNotificationListViewModel.defaultMock
        let component = NotificationListView(viewModel: viewModel)
        
        component.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(component)
        
        NSLayoutConstraint.activate([
            component.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            component.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16),
            component.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor, constant: 20),
            component.bottomAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.bottomAnchor, constant: 20),
            
        ])
        
        vc.view.backgroundColor = StyleProvider.Color.backgroundSecondary
        return vc
    }
}

@available(iOS 17.0, *)
#Preview("Empty State") {
    PreviewUIViewController {
        let vc = UIViewController()
        let viewModel = MockNotificationListViewModel.emptyMock
        let component = NotificationListView(viewModel: viewModel)
        
        component.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(component)
        
        NSLayoutConstraint.activate([
            component.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            component.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16),
            component.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor, constant: 20),
            component.heightAnchor.constraint(equalToConstant: 400)
        ])
        
        vc.view.backgroundColor = StyleProvider.Color.backgroundSecondary
        return vc
    }
}
#endif
