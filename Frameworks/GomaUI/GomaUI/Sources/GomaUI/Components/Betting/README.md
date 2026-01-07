# Betting Components

This folder contains UI components for betting markets, outcomes, betslip, tickets, and cashout functionality.

## Markets & Outcomes

| Component | Description |
|-----------|-------------|
| `OutcomeItemView` | Individual betting outcome with selection states and odds animations |
| `MarketOutcomesLineView` | Horizontal betting market outcomes with selection and odds changes |
| `MarketOutcomesMultiLineView` | Multiple betting lines in vertical layout (2 or 3 columns) |
| `MarketInfoLineView` | Market information display line |
| `MarketNamePillLabelView` | Pill-shaped label for betting markets with loading states |
| `MarketGroupSelectorTabView` | Horizontal scrollable tab bar for market groups |
| `MarketGroupTabItemView` | Individual tab item for market group selector |
| `OddsAcceptanceView` | Odds acceptance toggle/selector |

## Betslip Components

| Component | Description |
|-----------|-------------|
| `BetslipFloatingView` | Floating betslip indicator/button |
| `BetslipHeaderView` | Betslip header with count and total |
| `BetslipTicketView` | Complete betslip ticket display |
| `BetslipTypeSelectorView` | Bet type selector (single, combo, system) |
| `BetslipTypeTabItemView` | Individual bet type tab item |
| `BetslipOddsBoostHeaderView` | Odds boost promotion header for betslip |

## Ticket & Bet Details

| Component | Description |
|-----------|-------------|
| `TicketSelectionView` | Sports betting ticket with PreLive/Live states |
| `TicketBetInfoView` | Comprehensive betting ticket information |
| `BetDetailRowView` | Individual bet detail row |
| `BetDetailResultSummaryView` | Bet result summary display |
| `BetDetailValuesSummaryView` | Bet values summary (stake, odds, payout) |
| `BetInfoSubmissionView` | Bet submission information |
| `BetSummaryRowView` | Bet summary row display |
| `BetTicketStatusView` | Bet ticket status indicator |

## Cashout Components

| Component | Description |
|-----------|-------------|
| `CashoutAmountView` | Cashout amount display |
| `CashoutSliderView` | Partial cashout slider |
| `CashoutSubmissionInfoView` | Cashout submission information |

## Other

| Component | Description |
|-----------|-------------|
| `SuggestedBetsExpandedView` | Expandable section with horizontal match cards |

## Component Hierarchy

```
BetslipTicketView (composite)
├── BetslipHeaderView
├── BetslipTypeSelectorView
│   └── BetslipTypeTabItemView
└── TicketBetInfoView

MarketOutcomesLineView (composite)
└── OutcomeItemView (multiple)

MarketOutcomesMultiLineView (composite)
└── MarketOutcomesLineView (multiple)
```

## Architecture

All components follow GomaUI's standard MVVM pattern with protocol-driven ViewModels, mock implementations, and Combine-based reactive bindings.
