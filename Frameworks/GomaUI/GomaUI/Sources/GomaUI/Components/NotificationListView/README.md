# NotificationListView

A vertical scrollable list of notification cards with loading, empty, and error states.

## Overview

NotificationListView displays a collection of notifications using UICollectionView with self-sizing cells. Each notification shows timestamp, title, description, and optional action button. Cards have position-based corner rounding (first/last/single/middle) and support read/unread visual states. The component handles loading, empty, and error states with appropriate UI feedback.

## Component Relationships

### Used By (Parents)
- Notification center screens
- Inbox views

### Uses (Children)
- `NotificationCardView` (via NotificationCardCollectionViewCell)

## Features

- Vertical scrolling collection view
- Self-sizing cells based on content
- Loading state with activity indicator
- Empty state with localized message
- Error state with error message
- Position-based card corner rounding
- Read/unread visual states
- Optional action button per notification
- Mark as read on tap
- Refresh and load more support
- Reactive updates via Combine publishers

## Usage

```swift
let viewModel = MockNotificationListViewModel.defaultMock
let notificationList = NotificationListView(viewModel: viewModel)

// Setup callbacks
viewModel.onActionPerformed = { notification in
    handleAction(notification)
}

viewModel.onNotificationRead = { notification in
    updateUnreadCount()
}

viewModel.onRefreshCompleted = {
    endRefreshing()
}

viewModel.onError = { error in
    showError(error)
}

// Refresh the list
notificationList.refresh()

// Mark specific notification as read
notificationList.markAsRead(notificationId: "notif_1")
```

## Data Model

```swift
enum NotificationListState {
    case loading
    case loaded([NotificationData])
    case empty
    case error(Error)
}

struct NotificationData: Equatable, Hashable {
    let id: String
    let timestamp: Date
    let title: String
    let description: String
    let state: NotificationState    // .read or .unread
    let action: NotificationAction?

    var isUnread: Bool { state == .unread }
    var hasAction: Bool { action != nil }
}

struct NotificationAction: Equatable, Hashable {
    let id: String
    let title: String
    let style: ActionStyle  // .primary or .secondary
}

enum CardPosition {
    case single  // All corners rounded
    case first   // Top corners rounded
    case middle  // No corners rounded
    case last    // Bottom corners rounded
}

protocol NotificationListViewModelProtocol {
    var notificationListStatePublisher: AnyPublisher<NotificationListState, Never> { get }
    var notificationsPublisher: AnyPublisher<[NotificationData], Never> { get }
    var isLoadingPublisher: AnyPublisher<Bool, Never> { get }
    var notifications: [NotificationData] { get }
    var isLoading: Bool { get }
    var unreadCount: Int { get }

    func refresh()
    func loadMore()
    func markAsRead(notificationId: String)
    func markAllAsRead()
    func performAction(for notification: NotificationData)
    func deleteNotification(notificationId: String)
    func clearAllNotifications()
}
```

## Styling

StyleProvider properties used:
- `StyleProvider.Color.textSecondary` - empty state text color
- `StyleProvider.Color.highlightPrimary` - loading indicator color
- `StyleProvider.fontWith(type: .medium, size: 16)` - empty state font
- `StyleProvider.fontWith(type: .bold, size: 14)` - title font (for height calc)
- `StyleProvider.fontWith(type: .regular, size: 12)` - description font (for height calc)

Layout constants:
- Section insets: 8pt all sides
- Minimum line spacing: 0pt (cards touch)
- Header height: 16pt + 16pt padding
- Title-description gap: 3pt
- Action button gap: 12pt
- Action button height: 33pt
- Minimum title height: 24pt
- Minimum description height: 16pt

Height calculation:
- Base: 16pt (top) + 16pt (header) + 16pt (bottom)
- Plus: title height + 3pt + description height
- Plus (if action): 12pt + 33pt

## Mock ViewModels

Available presets:
- `.defaultMock` - 4 notifications, mixed read/unread, with/without actions
- `.mixedNotificationsMock` - Welcome, payment, promo, verification types
- `.emptyMock` - Empty state
- `.loadingMock` - Loading state
- `.unreadOnlyMock` - 2 urgent unread notifications
- `.readOnlyMock` - 2 old read notifications
