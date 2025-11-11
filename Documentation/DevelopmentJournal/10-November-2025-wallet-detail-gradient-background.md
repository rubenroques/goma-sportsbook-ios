## Date
10 November 2025

### Project / Branch
sportsbook-ios / betsson-cm

### Goals for this session
- Add horizontal gradient background to WalletDetailView component in GomaUI
- Use StyleProvider gradient colors (backgroundGradientDark → backgroundGradientLight)
- Maintain white header section while showing gradient in balance area

### Achievements
- [x] Understood WalletDetailView component architecture and composition
- [x] Identified reusable GradientView component in GomaUI
- [x] Implemented proper view hierarchy with gradient as background layer
- [x] Configured horizontal left-to-right gradient using StyleProvider colors
- [x] Preserved white WalletDetailHeaderView while gradient shows in balance section

### Key Decisions
- **View hierarchy structure**: Chose to have `containerView (UIView)` with `gradientView` as background layer and `stackView` on top, rather than making containerView itself a GradientView
  - Reasoning: Cleaner separation of concerns - gradient is purely decorative background
  - Pattern follows established GomaUI convention (see MatchHeaderCompactView)
- **Corner radius handling**: Applied cornerRadius to gradientView in `layoutSubviews()` using GradientView's native property
- **Sub-component backgrounds**: WalletDetailHeaderView keeps white background, all other components (WalletDetailBalanceView, WalletDetailBalanceLineView) already have clear backgrounds

### Implementation Details

**File Modified**: `Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/WalletDetailView/WalletDetailView.swift`

**Changes Made**:
1. Added `gradientView: GradientView` property
2. Kept `containerView: UIView` (clear background)
3. Created `createGradientView()` factory method with:
   - Colors: `StyleProvider.Color.backgroundGradientDark` (0.0) → `backgroundGradientLight` (1.0)
   - Direction: Horizontal (left to right via `setHorizontalGradient()`)
   - Corner radius: 8px
4. Updated `setupSubviews()` to add gradient first, then content on top
5. Added gradient constraints to fill entire containerView
6. Updated `layoutSubviews()` to apply cornerRadius to gradientView
7. Removed solid orange background color assignment from `setupWithTheme()`

**Final View Hierarchy**:
```
WalletDetailView
└── containerView (UIView - clear)
    ├── gradientView (GradientView - background layer)
    └── stackView
        ├── headerView (WalletDetailHeaderView - white background)
        ├── balanceView (WalletDetailBalanceView - clear, shows gradient)
        └── buttonsContainerView (clear, shows gradient)
            ├── withdrawButton
            └── depositButton
```

### Experiments & Notes
- Initially attempted to make containerView itself a GradientView, but user correctly pointed out it's cleaner to have gradient as a separate background layer
- GomaUI's GradientView component is well-designed and reusable:
  - Supports multiple gradient directions (horizontal, vertical, diagonal, radial)
  - Uses StyleProvider colors for theming
  - Has built-in cornerRadius property
  - Follows established pattern used in MatchHeaderCompactView, PromotionalBonusCardView

### Useful Files / Links
- [WalletDetailView](Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/WalletDetailView/WalletDetailView.swift)
- [GradientView Helper](Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/HelperViews/GradientView.swift)
- [StyleProvider Colors](Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/StyleProvider/StyleProvider.swift)
- [MatchHeaderCompactView Reference](Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/MatchHeaderCompactView/MatchHeaderCompactView.swift)

### Next Steps
1. Test gradient appearance in GomaUIDemo app with all mock states
2. Verify gradient shows correctly in Betsson Cameroon ProfileWallet screen
3. Consider if gradient colors need adjustment for better visual hierarchy
