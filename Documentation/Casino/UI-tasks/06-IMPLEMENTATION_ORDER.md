# Casino UI Components Implementation Order

## Overview

This document outlines the step-by-step implementation order for all casino UI components, ensuring proper dependency management and logical progression from simple to complex components.

## Implementation Strategy

### Principles
1. **Dependency-First**: Implement components with no dependencies before components that use them
2. **Test-As-You-Go**: Each component should be fully tested before moving to the next
3. **Progressive Complexity**: Start with simple leaf components, then build container components
4. **Demo Integration**: Add each component to the demo app immediately after implementation

## Phase 1: Foundation Components (Leaf Components)

These components have no dependencies on other casino components and can be implemented independently.

### Step 1: CasinoGameCardView 
**Priority: HIGHEST** ⭐⭐⭐

**Why First**: This is the most fundamental component used by all other casino components.

**Implementation Tasks**:
1. Create `CasinoGameCardViewModelProtocol.swift`
2. Create `CasinoGameCardView.swift` 
3. Create `MockCasinoGameCardViewModel.swift`
4. Add SwiftUI previews with all states
5. Create demo view controller `CasinoGameCardViewController.swift`
6. Add to `ComponentsTableViewController.swift` gallery
7. Test all states (loading, error, different ratings, etc.)

**Verification Checklist**:
- [ ] All UI elements render correctly (image, title, provider, stars, min stake)
- [ ] Star rating displays correctly for all values (0-5, including half stars)
- [ ] Image loading states work (loading, success, failure)
- [ ] Favorite toggling works
- [ ] Game selection callback works
- [ ] SwiftUI previews show all states
- [ ] Demo app integration works
- [ ] Accessibility support complete

**Estimated Time**: 1-2 days

---

### Step 2: CasinoRecentlyPlayedCardView
**Priority: HIGH** ⭐⭐

**Why Second**: Specialized horizontal card component needed by recently played section.

**Implementation Tasks**:
1. Create `CasinoRecentlyPlayedCardViewModelProtocol.swift`
2. Create `CasinoRecentlyPlayedCardView.swift` 
3. Create `MockCasinoRecentlyPlayedCardViewModel.swift`
4. Add SwiftUI previews with all states
5. Create demo view controller `CasinoRecentlyPlayedCardViewController.swift`
6. Add to `ComponentsTableViewController.swift` gallery
7. Test all states (loading, error, different games)

**Verification Checklist**:
- [ ] Horizontal layout renders correctly (image left, text right)
- [ ] Game image displays with loading and error states
- [ ] Game title and provider text display properly
- [ ] Landscape card size (280×120pt) is correct
- [ ] Game selection callback works
- [ ] SwiftUI previews show all states
- [ ] Demo app integration works
- [ ] Accessibility support complete
- [ ] Distinct from main CasinoGameCardView

**Estimated Time**: 1 day

---

### Step 3: CasinoCategoryHeaderView
**Priority: HIGH** ⭐⭐

**Why Third**: Simple component with no dependencies, needed by container components.

**Implementation Tasks**:
1. Create `CasinoCategoryHeaderViewModelProtocol.swift`
2. Create `CasinoCategoryHeaderView.swift`
3. Create `MockCasinoCategoryHeaderViewModel.swift`
4. Add SwiftUI previews
5. Create demo view controller `CasinoCategoryHeaderViewController.swift`
6. Add to `ComponentsTableViewController.swift` gallery
7. Test different category names and counts

**Verification Checklist**:
- [ ] Header text displays correctly
- [ ] "All X >" button shows correct count
- [ ] Button tap callback works
- [ ] Loading state shows/hides button appropriately
- [ ] Different category names render properly
- [ ] SwiftUI previews work
- [ ] Demo app integration works
- [ ] Accessibility support complete

**Estimated Time**: 0.5-1 day

---

## Phase 2: Wrapper Components

Simple wrapper components that use the leaf components.

### Step 4: CasinoGameCollectionViewCell
**Priority: MEDIUM** ⭐

**Why Fourth**: Simple wrapper for the game card, needed by collection components.

**Implementation Tasks**:
1. Create `CasinoGameCollectionViewCell.swift`
2. Implement proper cell reuse handling
3. Create demo view controller `CasinoGameCollectionViewCellViewController.swift`
4. Add to `ComponentsTableViewController.swift` gallery
5. Test cell reuse and memory management

**Verification Checklist**:
- [ ] Cell configuration works correctly
- [ ] `prepareForReuse()` cleans up properly
- [ ] Callback forwarding works
- [ ] Size calculations are correct
- [ ] Collection view integration smooth
- [ ] Memory management verified (no leaks)
- [ ] Demo app shows collection scrolling
- [ ] Performance is good with many cells

**Estimated Time**: 0.5 day

---

## Phase 3: Container Components

Components that combine multiple other components.

### Step 5: CasinoRecentlyPlayedView
**Priority: MEDIUM** ⭐

**Why Fifth**: Uses CasinoRecentlyPlayedCardView but has simpler logic than scrolling collections.

**Dependencies**: 
- ✅ CasinoRecentlyPlayedCardView (from Step 2)

**Implementation Tasks**:
1. Create `CasinoRecentlyPlayedViewModelProtocol.swift`
2. Create `CasinoRecentlyPlayedView.swift`
3. Create `MockCasinoRecentlyPlayedViewModel.swift`
4. Add SwiftUI previews
5. Create demo view controller `CasinoRecentlyPlayedViewController.swift`
6. Add to `ComponentsTableViewController.swift` gallery
7. Test all states (empty, loading, error, with games)

**Verification Checklist**:
- [ ] Recently played cards display using CasinoRecentlyPlayedCardView
- [ ] Empty state shows appropriate message
- [ ] Loading state shows loading indicator
- [ ] Error state shows error message with retry
- [ ] Game selection callbacks work
- [ ] Maximum 2 games displayed correctly
- [ ] Game sorting by last played date works
- [ ] Horizontal landscape card layout displays correctly
- [ ] SwiftUI previews show all states
- [ ] Demo app integration works
- [ ] Accessibility support complete

**Estimated Time**: 1 day

---

### Step 6: CasinoCategoryScrollView
**Priority: HIGH** ⭐⭐

**Why Sixth**: Complex container that uses both header and collection cell components.

**Dependencies**: 
- ✅ CasinoCategoryHeaderView (from Step 3)
- ✅ CasinoGameCollectionViewCell (from Step 4)
- ✅ CasinoGameCardView (from Step 1, via cell)

**Implementation Tasks**:
1. Create `CasinoCategoryScrollViewModelProtocol.swift`
2. Create `CasinoCategoryScrollView.swift`
3. Implement header bridge component
4. Create `MockCasinoCategoryScrollViewModel.swift`
5. Add SwiftUI previews
6. Create demo view controller `CasinoCategoryScrollViewController.swift`
7. Add to `ComponentsTableViewController.swift` gallery
8. Test scrolling performance with many games

**Verification Checklist**:
- [ ] Category header integrates properly
- [ ] Horizontal scrolling collection works smoothly  
- [ ] "View All" button callback works
- [ ] Game selection callbacks work
- [ ] Favorite toggling callbacks work
- [ ] Loading states (initial and load more) work
- [ ] Error states show appropriate messages
- [ ] Empty states handled gracefully
- [ ] Collection view cell reuse working
- [ ] Performance good with 20+ games
- [ ] SwiftUI previews show different categories
- [ ] Demo app shows multiple categories
- [ ] Accessibility support complete

**Estimated Time**: 1.5-2 days

---

## Phase 4: Integration Testing

After all components are implemented, comprehensive integration testing.

### Step 7: Full Integration Testing
**Priority: HIGH** ⭐⭐

**Testing Tasks**:
1. Test all components together in a single view controller
2. Performance testing with realistic data loads
3. Memory leak testing
4. Accessibility testing across all components
5. Different screen sizes and orientations
6. Dynamic Type support verification
7. Dark mode support (if applicable)

**Integration Scenarios**:
- Recently played section + multiple category scroll sections
- Empty recently played + full categories
- Loading states in multiple components simultaneously
- Error recovery across components
- Deep callback chains (game selection, favorite toggling)

**Verification Checklist**:
- [ ] All components work together without conflicts
- [ ] Performance remains smooth with full data set
- [ ] No memory leaks detected
- [ ] Accessibility works across component boundaries
- [ ] All screen sizes supported
- [ ] Dynamic Type works in all components
- [ ] Callback chains work correctly
- [ ] Error states don't interfere with each other
- [ ] Loading states coordinate properly

**Estimated Time**: 1 day

---

## Phase 5: Documentation and Cleanup

### Step 8: Final Documentation and Polish
**Priority: MEDIUM** ⭐

**Documentation Tasks**:
1. Update README files for each component
2. Add comprehensive code comments
3. Create usage examples in documentation
4. Document any architectural decisions made
5. Create troubleshooting guides

**Cleanup Tasks**:
1. Remove any debug code or comments
2. Ensure consistent naming conventions
3. Verify all preview states work
4. Ensure demo app is polished and presentable
5. Performance optimization if needed

**Estimated Time**: 0.5 day

---

## Total Implementation Timeline

| Phase | Duration | Components |
|-------|----------|------------|
| Phase 1 | 3.5-4 days | CasinoGameCardView, CasinoRecentlyPlayedCardView, CasinoCategoryHeaderView |
| Phase 2 | 0.5 day | CasinoGameCollectionViewCell |
| Phase 3 | 2.5-3 days | CasinoRecentlyPlayedView, CasinoCategoryScrollView |
| Phase 4 | 1 day | Integration Testing |
| Phase 5 | 0.5 day | Documentation & Cleanup |
| **Total** | **7.5-9 days** | **All Components** |

## Daily Implementation Plan

### Day 1: CasinoGameCardView Foundation
- Morning: Protocol and data models
- Afternoon: Basic UI implementation and constraints
- Evening: Image loading and star rating logic

### Day 2: CasinoGameCardView Completion + CasinoRecentlyPlayedCardView Start
- Morning: Complete CasinoGameCardView (previews, demo, testing)
- Afternoon: Start CasinoRecentlyPlayedCardView protocol and data models
- Evening: CasinoRecentlyPlayedCardView basic UI implementation

### Day 3: CasinoRecentlyPlayedCardView Completion + CasinoCategoryHeaderView
- Morning: Complete CasinoRecentlyPlayedCardView (previews, demo, testing)
- Afternoon: Full CasinoCategoryHeaderView implementation
- Evening: Testing and demo integration

### Day 4: CasinoGameCollectionViewCell + CasinoRecentlyPlayedView Start
- Morning: Collection view cell wrapper
- Afternoon: Start CasinoRecentlyPlayedView
- Evening: Complete CasinoRecentlyPlayedView basic functionality

### Day 5: CasinoRecentlyPlayedView Completion + CasinoCategoryScrollView Start
- Morning: Complete CasinoRecentlyPlayedView (all states, testing)
- Afternoon: Start CasinoCategoryScrollView architecture
- Evening: Basic CasinoCategoryScrollView implementation

### Day 6: CasinoCategoryScrollView Completion
- Morning: Complete CasinoCategoryScrollView implementation
- Afternoon: Testing and performance optimization
- Evening: Demo integration and preview states

### Day 7: Integration Testing
- Morning: Full integration testing
- Afternoon: Performance and memory testing
- Evening: Accessibility and edge case testing

### Day 8: Documentation and Polish
- Morning: Documentation updates
- Afternoon: Code cleanup and final testing
- Evening: Demo app polish and final verification

## Risk Mitigation

### Potential Blockers
1. **Image Loading Performance**: May need custom image caching solution
   - **Mitigation**: Start with simple URLSession, upgrade if needed
   
2. **Collection View Performance**: Many game cards in scroll views
   - **Mitigation**: Implement proper cell reuse and lazy loading
   
3. **Complex State Management**: Multiple loading/error states
   - **Mitigation**: Use clear state enums and comprehensive testing

4. **Layout Complexity**: Horizontal scrolling within vertical scrolling
   - **Mitigation**: Careful constraint setup and testing on multiple devices

### Success Criteria

Each component must meet these criteria before moving to the next:

1. **Visual Fidelity**: Matches Figma designs exactly
2. **Functionality**: All interactive elements work correctly
3. **Performance**: Smooth scrolling and quick response times
4. **Memory Management**: No memory leaks or excessive usage
5. **Accessibility**: Full VoiceOver and Dynamic Type support
6. **Testing**: Comprehensive preview states and demo integration
7. **Documentation**: Complete documentation and code comments

## Post-Implementation

After all components are complete:

1. **Code Review**: Comprehensive review of all component code
2. **Performance Benchmarking**: Measure and document performance metrics
3. **User Testing**: Test with real users if possible
4. **Maintenance Planning**: Document any ongoing maintenance needs

This implementation plan ensures a systematic, dependency-aware approach to building all casino UI components with proper testing and integration at each step.