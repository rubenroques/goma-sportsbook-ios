# Wallet Components

This folder contains UI components for wallet, balance display, transactions, and deposit/withdraw functionality.

## Components

### Wallet Display
| Component | Description |
|-----------|-------------|
| `WalletWidgetView` | Compact wallet balance display with deposit action |
| `WalletStatusView` | Wallet balance with deposit/withdraw actions (overlay dialogs) |
| `WalletDetailView` | Comprehensive wallet detail with balance and action buttons |

### Amount Selection
| Component | Description |
|-----------|-------------|
| `AmountPillView` | Individual amount selection pill |
| `AmountPillsContainerView` | Container for amount selection pills |

### Transactions
| Component | Description |
|-----------|-------------|
| `TransactionItemView` | Individual transaction display (deposits, withdrawals, bets) |
| `TransactionVerificationView` | Transaction verification component |
| `PendingWithdrawView` | Pending withdrawal request display |

### Bonus
| Component | Description |
|-----------|-------------|
| `DepositBonusInfoView` | Deposit bonus information display |

## Component Hierarchy

```
WalletDetailView (composite)
├── Balance display
└── Action buttons (deposit/withdraw)

AmountPillsContainerView (composite)
└── AmountPillView (multiple)
```

## Usage

These components are used in:
- Wallet/account screens
- Deposit flow
- Withdrawal flow
- Transaction history
- Balance overlays

## Architecture

All components follow GomaUI's standard MVVM pattern with protocol-driven ViewModels, mock implementations, and Combine-based reactive bindings.
