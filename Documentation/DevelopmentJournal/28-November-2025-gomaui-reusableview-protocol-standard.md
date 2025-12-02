# GomaUI ReusableView Protocol Standard

## Date
28 November 2025

### Project / Branch
sportsbook-ios / rr/feature/SPOR-6622-new-casino-layout

### Goals for this session
- Investigate GomaUI best practices for components inside UITableViewCell/UICollectionViewCell
- Document cell reuse patterns and requirements
- Standardize approach for all GomaUI components

### Achievements
- [x] Researched existing cell reuse patterns in GomaUI codebase
- [x] Identified dual-access pattern (`currentDisplayState` + `displayStatePublisher`) used in production components
- [x] Discovered `dropFirst()` pattern to avoid double-rendering after synchronous state access
- [x] Defined `ReusableView` protocol standard for all GomaUI components
- [x] Updated `Frameworks/GomaUI/CLAUDE.md` with comprehensive cell reuse documentation
- [x] Analyzed Swift concurrency vs Combine for this use case (conclusion: same fundamental pattern needed)

### Issues / Bugs Hit
- None - this was a documentation/standardization session

### Key Decisions
- **All GomaUI components must conform to `ReusableView` protocol** - no exceptions
- **ViewModels must be optional** - components must render blank/empty state when ViewModel is nil
- **Reactive ViewModels must expose `currentDisplayState`** - for synchronous access during cell configuration
- **Must use `CurrentValueSubject`** (not `PassthroughSubject`) to back publishers
- **Use `dropFirst()` in bindings** - since initial state is rendered synchronously, skip first publisher emission
- **Swift concurrency wouldn't simplify this** - UIKit's synchronous nature requires sync state access regardless of async framework used

### Experiments & Notes

**Why synchronous access is required:**
UITableView/UICollectionView calculate cell sizes synchronously in `cellForRowAt`/`sizeForItemAt`. Combine publishers have a micro-delay before emitting, causing layout calculations to happen before data arrives. This breaks Auto Layout when view sizing depends on ViewModel data.

**The complete cell reuse lifecycle:**
```
1. Cell dequeued
2. prepareForReuse() → view enters blank state (nil ViewModel)
3. configure(with:) → sync render with currentDisplayState
4. setupBindings() → dropFirst() for future reactive updates
```

**ReusableView protocol pattern:**
```swift
public protocol ReusableView {
    func prepareForReuse()
}

final class SomeView: UIView, ReusableView {
    private var viewModel: SomeViewModelProtocol?  // Optional!

    func prepareForReuse() {
        cancellables.removeAll()
        viewModel = nil
        onCallback = {}
        childView.prepareForReuse()
        renderEmptyState()
    }

    func configure(with viewModel: SomeViewModelProtocol) {
        self.viewModel = viewModel
        render(state: viewModel.currentDisplayState)  // Sync first
        setupBindings()  // Then reactive with dropFirst()
    }
}
```

**Swift concurrency analysis:**
Evaluated whether async/await would simplify the pattern. Conclusion: No - UIKit callbacks are synchronous, so you still need sync state access. The pattern would be nearly identical, just replacing `cancellables.removeAll()` with `task?.cancel()` and `@MainActor` instead of `receive(on: DispatchQueue.main)`.

### Useful Files / Links
- [GomaUI CLAUDE.md](../../Frameworks/GomaUI/CLAUDE.md) - Updated with ReusableView standard
- [ComponentCreationGuide.md](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Documentation/ComponentCreationGuide.md) - Component creation patterns
- [24-November-2025 Cell Reuse Fix Journal](./24-November-2025-fix-cell-reuse-market-outcomes.md) - Related investigation
- [TallOddsMatchCardView.swift](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/TallOddsMatchCardView/TallOddsMatchCardView.swift) - Reference implementation with dropFirst()
- [CasinoGameCardCollectionViewCell.swift](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/CasinoGameCardView/CasinoGameCardCollectionViewCell.swift) - Wrapper cell example

### Next Steps
1. Consider creating actual `ReusableView` protocol in GomaUI codebase
2. Audit existing components for conformance to new standard
3. Update ComponentCreationGuide.md to reference the ReusableView requirements
4. Add compile-time check or linter rule for ReusableView conformance

---

## Documentation Added to CLAUDE.md

**Section 4 - ReusableView Protocol:**
- All components must conform to `ReusableView`
- ViewModel must be optional (handle nil with blank state)
- `prepareForReuse()` clears cancellables, resets callbacks, nils ViewModel, clears visuals

**Section 5 - Synchronous State Access:**
- Reactive ViewModels must expose `currentDisplayState` + `displayStatePublisher`
- Must use `CurrentValueSubject` (not `PassthroughSubject`)
- Bindings use `.dropFirst()` to avoid double-render
