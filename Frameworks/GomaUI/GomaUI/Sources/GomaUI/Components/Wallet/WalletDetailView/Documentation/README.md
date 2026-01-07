# WalletDetailView

A comprehensive wallet detail display component that shows wallet information, balances, and action buttons in an orange-themed overlay design. Perfect for modals, overlays, or embedded wallet displays.

## Features

- **White header section** with wallet icon and title
- **Total XAF Balance** with cash icon
- **Four balance types**: Current, Bonus, Cashback, Withdrawable amounts
- **Action buttons** for Withdraw and Deposit operations
- **Orange gradient background** with rounded corners
- **Reactive architecture** with Combine publishers for real-time updates
- **Comprehensive mock states** for testing and development

## Visual Design

The component follows the Figma specification:
- Orange background (#ff6600) with 8px corner radius
- White header section with wallet branding
- Balance lines with white text on orange background
- Two action buttons at the bottom (bordered withdraw, filled deposit)
- Total dimensions approximately 350x291px

## Usage Example

### Basic Implementation

```swift
// Create view model (or use mock for testing)
let viewModel = MockWalletDetailViewModel.defaultMock

// Create the wallet detail view
let walletDetailView = WalletDetailView(viewModel: viewModel)

// Add to your view hierarchy
parentView.addSubview(walletDetailView)

// Set up constraints (typically centered with fixed width)
NSLayoutConstraint.activate([
    walletDetailView.centerXAnchor.constraint(equalTo: parentView.centerXAnchor),
    walletDetailView.centerYAnchor.constraint(equalTo: parentView.centerYAnchor),
    walletDetailView.leadingAnchor.constraint(greaterThanOrEqualTo: parentView.leadingAnchor, constant: 20),
    walletDetailView.trailingAnchor.constraint(lessThanOrEqualTo: parentView.trailingAnchor, constant: -20)
])

// Handle button actions
walletDetailView.onWithdraw = {
    // Navigate to withdrawal screen or show withdrawal flow
    print("User wants to withdraw funds")
}

walletDetailView.onDeposit = {
    // Navigate to deposit screen or show deposit flow
    print("User wants to deposit funds")
}
```

### Modal/Overlay Usage

```swift
// Create semi-transparent overlay
let overlayView = UIView()
overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
overlayView.translatesAutoresizingMaskIntoConstraints = false

// Add to window or root view
view.addSubview(overlayView)
NSLayoutConstraint.activate([
    overlayView.topAnchor.constraint(equalTo: view.topAnchor),
    overlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
    overlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
    overlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
])

// Add wallet detail view to overlay
let walletDetailView = WalletDetailView(viewModel: viewModel)
walletDetailView.translatesAutoresizingMaskIntoConstraints = false
overlayView.addSubview(walletDetailView)

NSLayoutConstraint.activate([
    walletDetailView.centerXAnchor.constraint(equalTo: overlayView.centerXAnchor),
    walletDetailView.centerYAnchor.constraint(equalTo: overlayView.centerYAnchor),
    walletDetailView.leadingAnchor.constraint(greaterThanOrEqualTo: overlayView.leadingAnchor, constant: 20),
    walletDetailView.trailingAnchor.constraint(lessThanOrEqualTo: overlayView.trailingAnchor, constant: -20)
])

// Add tap to dismiss
let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissWalletOverlay))
overlayView.addGestureRecognizer(tapGesture)
```

### Production Implementation

In production, your view model would connect to real wallet services:

```swift
class ProductionWalletDetailViewModel: WalletDetailViewModelProtocol {
    private let walletService: WalletServiceProtocol
    private let displayStateSubject = CurrentValueSubject<WalletDetailDisplayState, Never>(/* initial state */)
    private let totalBalanceSubject = CurrentValueSubject<String, Never>("0.00")
    // ... other subjects
    
    init(walletService: WalletServiceProtocol) {
        self.walletService = walletService
        
        // Subscribe to wallet updates
        walletService.walletUpdates
            .map { wallet in
                WalletDetailData(
                    walletTitle: wallet.name,
                    totalBalance: NumberFormatter.currency.string(from: wallet.totalBalance) ?? "0.00",
                    currentBalance: NumberFormatter.currency.string(from: wallet.currentBalance) ?? "0.00",
                    bonusBalance: NumberFormatter.currency.string(from: wallet.bonusBalance) ?? "0.00",
                    cashbackBalance: NumberFormatter.currency.string(from: wallet.cashbackBalance) ?? "0.00",
                    withdrawableAmount: NumberFormatter.currency.string(from: wallet.withdrawableAmount) ?? "0.00"
                )
            }
            .sink { [weak self] walletData in
                let newState = WalletDetailDisplayState(walletData: walletData)
                self?.displayStateSubject.send(newState)
                self?.updateIndividualPublishers(from: walletData)
            }
            .store(in: &cancellables)
    }
    
    func performWithdraw() {
        coordinator.navigateToWithdraw()
    }
    
    func performDeposit() {
        coordinator.navigateToDeposit()
    }
    
    // Implement other protocol requirements...
}
```

## Component Architecture

### Multi-Component Design

The WalletDetailView is composed of several reusable sub-components:

#### WalletDetailHeaderView
- White background container with rounded corners
- Wallet icon (MTN branding) with yellow background
- "Wallet" title label
- Clean, simple header design

#### WalletDetailBalanceView
- Total XAF Balance section with cash icon
- White separator lines
- Four balance line items:
  - Current Balance: Available funds
  - Bonus Balance: Promotional/bonus funds
  - Cashback Balance: Earned cashback
  - Withdrawable: Funds available for withdrawal
- Reactive binding to balance publishers

### Benefits of Modular Design
- **Maintainability**: Each section is self-contained
- **Reusability**: Header and balance sections can be used elsewhere
- **Testability**: Individual components can be tested in isolation
- **Type Safety**: No casting or unsafe UI element access
- **Consistent Styling**: Unified StyleProvider usage

## Mock States & Testing

The component includes comprehensive mock implementations:

### Available Mock States

```swift
// Default state matching Figma design
MockWalletDetailViewModel.defaultMock

// Empty wallet for testing zero states
MockWalletDetailViewModel.emptyBalanceMock

// High balances for layout stress testing
MockWalletDetailViewModel.highBalanceMock

// Bonus-only scenario (no withdrawable funds)
MockWalletDetailViewModel.bonusOnlyMock

// Cashback focus scenario
MockWalletDetailViewModel.cashbackFocusMock
```

### Dynamic Testing Methods

```swift
// Simulate balance updates
viewModel.simulateBalanceUpdate(
    total: "3,500.00",
    current: "2,000.00"
)

// Simulate successful deposit
viewModel.simulateDepositComplete(amount: 500.0)

// Simulate withdrawal
viewModel.simulateWithdrawalComplete(amount: 100.0)

// Test loading states
viewModel.simulateLoadingState()

// Refresh data (with loading simulation)
viewModel.refreshWalletData()
```

## Styling & Customization

### Colors (from StyleProvider)

The component uses StyleProvider for all visual properties:

- **Background**: `StyleProvider.Color.highlightPrimary` (orange)
- **Header background**: `StyleProvider.Color.backgroundTertiary` (white)
- **Text on white**: `StyleProvider.Color.textPrimary` (dark)
- **Text on orange**: `StyleProvider.Color.highlightPrimaryContrast` (white)
- **Icon background**: `StyleProvider.Color.highlightSecondary` (yellow)
- **Separators**: `StyleProvider.Color.highlightPrimaryContrast` (white)

### Typography

- **Wallet title**: Regular 12px
- **Balance labels**: Regular 14px
- **Balance values**: Bold 14px (right-aligned)
- **Total balance value**: Bold 18px
- **Button text**: Bold 12px

### Layout Specifications

- **Component padding**: 16px all sides
- **Section spacing**: 12px between header, balance, and buttons
- **Header height**: 48px fixed
- **Button height**: 40px fixed
- **Corner radius**: 8px for main container, header container
- **Icon sizes**: 32x32px (wallet icon), 24x24px (cash icon)

## Integration with Existing Components

### ButtonView Integration

The component uses GomaUI's existing ButtonView:

- **Withdraw Button**: `.bordered` style with white border
- **Deposit Button**: `.solidBackground` style with white background

### WalletBalanceLineView Integration

Leverages the existing `WalletBalanceLineView` component for consistent balance line formatting.

## SwiftUI Preview Support

The component includes comprehensive SwiftUI previews using `PreviewUIViewController`:

- Default state preview on orange background
- Interactive button tap logging
- Proper constraint setup examples
- Multiple mock state demonstrations

## File Structure

```
WalletDetailView/
├── WalletDetailView.swift                      # Main container component
├── WalletDetailHeaderView.swift                # White header section
├── WalletDetailBalanceView.swift               # Balance display section  
├── WalletDetailViewModelProtocol.swift         # Protocol definitions
├── MockWalletDetailViewModel.swift             # Mock implementations
└── Documentation/
    └── README.md                               # This documentation
```

## Requirements

- iOS 16.0+
- GomaUI StyleProvider
- GomaUI ButtonView component
- GomaUI WalletBalanceLineView component (from WalletStatusView)
- Combine framework for reactive bindings

## Design Decisions

### Why Multi-Component Architecture?

1. **Single Responsibility**: Each component has one clear purpose
2. **Reusability**: Header and balance sections can be used independently
3. **Testing**: Easier to test individual components in isolation
4. **Maintainability**: Changes to one section don't affect others
5. **Performance**: Smaller components with focused rendering logic

### Why Reactive Architecture?

1. **Real-time Updates**: Balance changes reflect immediately in UI
2. **Loose Coupling**: View doesn't need to know about data source
3. **Testability**: Easy to simulate different states via publishers
4. **Consistency**: Follows GomaUI's established patterns

This component provides a complete, production-ready wallet detail interface that matches the Figma specification while following GomaUI's architectural principles and design patterns.
