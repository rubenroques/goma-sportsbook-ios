# Status Components

This folder contains UI components for status displays, notifications, progress indicators, and empty states.

## Components

### Notifications & Alerts
| Component | Description |
|-----------|-------------|
| `StatusNotificationView` | Notification banner for status messages |
| `StatusInfoView` | Status info component with icon, title, and message |
| `FloatingOverlay` | Context-aware floating message overlay with auto-dismiss |
| `ToasterView` | Toast notification component |
| `NotificationListView` | Scrollable notification feed with card-based items |

### Progress & Loading
| Component | Description |
|-----------|-------------|
| `ProgressInfoCheckView` | Progress indicator with check states for multi-step flows |
| `ProgressSegments` | Segmented progress indicator |

### Empty States & Actions
| Component | Description |
|-----------|-------------|
| `EmptyStateActionView` | Empty state with icon, title, message, and action button |
| `SeeMoreButtonView` | "Load More" button with loading states |

## Usage

These components are used in:
- Success/error screens
- Loading states
- Empty list states
- Notification centers
- Multi-step flows

## Architecture

All components follow GomaUI's standard MVVM pattern with protocol-driven ViewModels, mock implementations, and Combine-based reactive bindings.
