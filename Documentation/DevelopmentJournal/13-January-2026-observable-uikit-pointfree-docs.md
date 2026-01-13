## Date
13 January 2026

### Project / Branch
GomaUI / wip/manual-distribute-refactor

### Goals for this session
- Read and understand OBSERVABLE_UIKIT.md and SNAPSHOT_TESTING.md documentation
- Research Point-Free's swift-navigation library and `observe { }` pattern
- Add Point-Free's approach to OBSERVABLE_UIKIT.md documentation
- Clarify iOS version requirements (iOS 17 vs iOS 18)

### Achievements
- [x] Read existing documentation on @Observable + layoutSubviews() pattern
- [x] Researched Point-Free's swift-navigation library via web search
- [x] Discovered critical iOS version distinction:
  - `@Observable` macro: iOS 17+
  - UIKit auto-tracking in `layoutSubviews()`: iOS 18+ (with plist key)
- [x] Added comprehensive Point-Free `observe { }` section to OBSERVABLE_UIKIT.md
- [x] Added "Choosing an Approach" comparison section
- [x] Fixed misleading iOS version claims throughout the document
- [x] Updated recommendations for iOS 17+ production apps (BetssonCameroon, BetssonFranceLegacy)
- [x] Added Point-Free resources to References section

### Issues / Bugs Hit
- None - documentation update only

### Key Decisions
- **Point-Free `observe { }` is recommended for production apps** targeting iOS 17+ since Apple's native UIKit auto-tracking requires iOS 18+
- **Apple's `layoutSubviews()` pattern** remains documented for:
  - GomaUICatalog (internal testing with plist key)
  - Future apps when iOS 18+ becomes minimum target
- Both patterns solve the same problem (Combine's async rendering) but have different iOS requirements

### Experiments & Notes
- The "iOS version gap" is a key insight: iOS 17 has `@Observable` but UIKit doesn't do anything with it until iOS 18
- Point-Free's `observe { }` provides the observation tracking context that UIKit lacks on iOS 17
- Perception library enables backporting to iOS 13+ using `@Perceptible` macro

### Useful Files / Links
- [OBSERVABLE_UIKIT.md](../../Frameworks/GomaUI/Documentation/Guides/OBSERVABLE_UIKIT.md) - Updated documentation
- [SNAPSHOT_TESTING.md](../../Frameworks/GomaUI/Documentation/Guides/SNAPSHOT_TESTING.md) - Related snapshot testing guide
- [swift-navigation](https://github.com/pointfreeco/swift-navigation) - Point-Free's UIKit observation library
- [Perception](https://github.com/pointfreeco/swift-perception) - @Observable backport for iOS 13+
- [Episode #283: Modern UIKit: Observation](https://www.pointfree.co/episodes/ep283-modern-uikit-observation) - Point-Free video
- [Peter Steinberger's Article](https://steipete.me/posts/2025/automatic-observation-tracking-uikit-appkit) - iOS 18 plist key discovery

### Next Steps
1. Consider adding swift-navigation package to production apps for iOS 17 `observe { }` support
2. Create example ViewController using `observe { }` pattern in BetssonCameroonApp
3. Evaluate migration path from Combine to `observe { }` for existing ViewControllers
4. Update GomaUI CLAUDE.md if `observe { }` becomes the standard pattern
