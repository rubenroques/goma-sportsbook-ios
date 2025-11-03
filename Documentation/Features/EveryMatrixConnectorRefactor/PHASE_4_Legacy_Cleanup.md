# Phase 4: Legacy Connector Cleanup

## Objective

Remove all legacy connector classes and feature flags after successful migration to the unified connector architecture. This is the final cleanup phase that simplifies the codebase.

**Duration:** 1 day
**Risk Level:** Low
**Breaking Changes:** None (already migrated)

---

## Prerequisites

✅ **Phase 3 completed:** All providers migrated
✅ **All feature flags enabled:** 100% rollout on all APIs
✅ **Stability confirmed:** At least 1 week of monitoring with no issues
✅ **Metrics validated:** No increase in error rates or degradation

---

## What Gets Deleted

### Connector Classes (4 files)

These classes are no longer used and can be safely deleted:

```
Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/
├── EveryMatrixOddsMatrixAPIConnector.swift          ← DELETE
├── EveryMatrixPlayerAPIConnector.swift              ← DELETE
├── EveryMatrixCasinoConnector.swift                 ← DELETE
└── EveryMatrixRecsysAPIConnector.swift              ← DELETE
```

**Total lines deleted:** ~150 lines

### Feature Flags (Client.swift)

Remove these feature flag properties:

```swift
// DELETE these lines from Client.swift (~line 55-70)
private let useUnifiedConnector_Recsys = true
private let useUnifiedConnector_OddsMatrix = true
private let useUnifiedConnector_PlayerAPI = true
private let useUnifiedConnector_Casino = true
```

---

## Implementation Steps

### Step 1: Remove Feature Flags from Client.swift

**File:** `Frameworks/ServicesProvider/Sources/ServicesProvider/Client.swift`

**What to delete:**

1. **Feature flag properties** (~lines 55-70):
   ```swift
   // DELETE:
   private let useUnifiedConnector_Recsys = true
   private let useUnifiedConnector_OddsMatrix = true
   private let useUnifiedConnector_PlayerAPI = true
   private let useUnifiedConnector_Casino = true
   ```

2. **Conditional logic in connect() method** (~lines 78-143):

   **RecsysAPI (lines ~92):**
   ```swift
   // BEFORE:
   let recsysConnector: EveryMatrixRecsysAPIConnector
   if useUnifiedConnector_Recsys {
       recsysConnector = EveryMatrixUnifiedConnector(
           apiType: .recsys,
           sessionCoordinator: sessionCoordinator
       )
   } else {
       recsysConnector = EveryMatrixRecsysAPIConnector(
           sessionCoordinator: sessionCoordinator
       )
   }

   // AFTER:
   let recsysConnector = EveryMatrixUnifiedConnector(
       apiType: .recsys,
       sessionCoordinator: sessionCoordinator
   )
   ```

   **OddsMatrix (lines ~110-112):**
   ```swift
   // BEFORE:
   let oddsMatrixConnector: EveryMatrixOddsMatrixAPIConnector
   if useUnifiedConnector_OddsMatrix {
       oddsMatrixConnector = EveryMatrixUnifiedConnector(
           apiType: .oddsMatrix,
           sessionCoordinator: sessionCoordinator
       )
   } else {
       oddsMatrixConnector = EveryMatrixOddsMatrixAPIConnector(
           sessionCoordinator: sessionCoordinator
       )
   }

   // AFTER:
   let oddsMatrixConnector = EveryMatrixUnifiedConnector(
       apiType: .oddsMatrix,
       sessionCoordinator: sessionCoordinator
   )
   ```

   **PlayerAPI (lines ~96-103):**
   ```swift
   // BEFORE:
   let playerAPIConnector: EveryMatrixPlayerAPIConnector
   if useUnifiedConnector_PlayerAPI {
       playerAPIConnector = EveryMatrixUnifiedConnector(
           apiType: .playerAPI,
           sessionCoordinator: sessionCoordinator
       )
   } else {
       playerAPIConnector = EveryMatrixPlayerAPIConnector(
           sessionCoordinator: sessionCoordinator
       )
   }

   // AFTER:
   let playerAPIConnector = EveryMatrixUnifiedConnector(
       apiType: .playerAPI,
       sessionCoordinator: sessionCoordinator
   )
   ```

   **Casino (lines ~105-108):**
   ```swift
   // BEFORE:
   let casinoConnector: EveryMatrixCasinoConnector
   if useUnifiedConnector_Casino {
       casinoConnector = EveryMatrixUnifiedConnector(
           apiType: .casino,
           sessionCoordinator: sessionCoordinator
       )
   } else {
       casinoConnector = EveryMatrixCasinoConnector(
           sessionCoordinator: sessionCoordinator
       )
   }

   // AFTER:
   let casinoConnector = EveryMatrixUnifiedConnector(
       apiType: .casino,
       sessionCoordinator: sessionCoordinator
   )
   ```

**Result:** ~60 lines deleted from Client.swift

---

### Step 2: Delete Legacy Connector Classes

**Command to execute:**
```bash
cd /Users/rroques/Desktop/GOMA/iOS/sportsbook-ios/Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix

# Delete the 4 legacy connector files
rm EveryMatrixOddsMatrixAPIConnector.swift
rm EveryMatrixPlayerAPIConnector.swift
rm EveryMatrixCasinoConnector.swift
rm EveryMatrixRecsysAPIConnector.swift
```

**Files to delete:**

1. **EveryMatrixOddsMatrixAPIConnector.swift** (24 lines)
   - Minimal subclass
   - Only passes "OddsMatrix" identifier

2. **EveryMatrixPlayerAPIConnector.swift** (35 lines)
   - Adds updateSessionToken() helper
   - Helper now exists in unified connector

3. **EveryMatrixCasinoConnector.swift** (43 lines)
   - Cookie authentication (now in CookieAuthStrategy)
   - Broken network monitoring code

4. **EveryMatrixRecsysAPIConnector.swift** (23 lines)
   - Minimal subclass
   - Only passes "RecsysAPI" identifier

**Total:** ~125 lines deleted

---

### Step 3: Remove Imports

**Files that imported legacy connectors:**

Check these files for unused imports:

```
Frameworks/ServicesProvider/Sources/ServicesProvider/
├── Providers/Everymatrix/
│   ├── EveryMatrixBettingProvider.swift
│   │   └── Remove: import for EveryMatrixOddsMatrixAPIConnector (if exists)
│   │
│   ├── EveryMatrixPrivilegedAccessManager.swift
│   │   └── Remove: import for EveryMatrixPlayerAPIConnector (if exists)
│   │
│   ├── EveryMatrixCasinoProvider.swift
│   │   └── Remove: import for EveryMatrixCasinoConnector (if exists)
│   │
│   └── EveryMatrixProvider.swift
│       └── Remove: import for EveryMatrixRecsysAPIConnector (if exists)
│
└── Client.swift
    └── Remove: imports for all 4 legacy connectors (if exists)
```

**Note:** These imports may not exist if they were in the same file. Check each file individually.

---

### Step 4: Update Type Annotations

**Files with type annotations:**

Some providers may have explicit type annotations that reference legacy connectors. Update these to use the unified connector or remove type annotation (let Swift infer).

**EveryMatrixBettingProvider.swift (~line 14):**
```swift
// BEFORE:
private var connector: EveryMatrixOddsMatrixAPIConnector

// AFTER (Option 1 - explicit):
private var connector: EveryMatrixUnifiedConnector

// AFTER (Option 2 - protocol):
private var connector: any EveryMatrixConnector  // If protocol exists
```

**EveryMatrixPrivilegedAccessManager.swift (~line 14):**
```swift
// BEFORE:
var connector: EveryMatrixPlayerAPIConnector

// AFTER:
var connector: EveryMatrixUnifiedConnector
```

**EveryMatrixCasinoProvider.swift (~line 6):**
```swift
// BEFORE:
private let connector: EveryMatrixCasinoConnector

// AFTER:
private let connector: EveryMatrixUnifiedConnector
```

**EveryMatrixProvider.swift (~line 19):**
```swift
// BEFORE:
private let recsysConnector: EveryMatrixRecsysAPIConnector

// AFTER:
private let recsysConnector: EveryMatrixUnifiedConnector
```

---

### Step 5: Fix Broken Network Monitoring

**Context:** `EveryMatrixCasinoConnector` had incomplete network monitoring code (lines 16-42):

```swift
private func setupNetworkMonitoring() {
    NotificationCenter.default.publisher(for: .NSURLCredentialStorageChanged)
        .sink { [weak self] _ in
            self?.checkConnectivity()
        }
        .store(in: &cancellables)
}

private func checkConnectivity() {
    connectionStateSubject.send(.connected)  // Always sends .connected?
}
```

**This code doesn't work properly** - it always sends `.connected` regardless of actual connectivity.

**Decision:**
- Delete this broken code
- If proper network monitoring is needed, implement it in base connector or unified connector
- Current behavior: Relies on HTTP errors to detect connection issues

**No action required** - deleting CasinoConnector removes this code.

---

## File References Summary

### Files to DELETE:

```
Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/
├── EveryMatrixOddsMatrixAPIConnector.swift          (24 lines)
├── EveryMatrixPlayerAPIConnector.swift              (35 lines)
├── EveryMatrixCasinoConnector.swift                 (43 lines)
└── EveryMatrixRecsysAPIConnector.swift              (23 lines)
```

### Files to MODIFY:

```
Frameworks/ServicesProvider/Sources/ServicesProvider/
├── Client.swift
│   ├── Delete feature flags (~lines 55-70)
│   └── Simplify connect() method (~lines 78-143)
│
└── Providers/Everymatrix/
    ├── EveryMatrixBettingProvider.swift
    │   └── Update type annotation for connector
    │
    ├── EveryMatrixPrivilegedAccessManager.swift
    │   └── Update type annotation for connector
    │
    ├── EveryMatrixCasinoProvider.swift
    │   └── Update type annotation for connector
    │
    └── EveryMatrixProvider.swift
        └── Update type annotation for recsysConnector
```

### Files to READ for verification:

```
EveryMatrixUnifiedConnector.swift
└── Verify all 4 API types are supported

EveryMatrixAPIType.swift
└── Verify enum cases match deleted connectors

EveryMatrixAuthenticationStrategy.swift
└── Verify all 3 strategies are implemented
```

---

## Testing Requirements

### Compilation Tests

**After deletion:**
1. Clean build folder
2. Run full workspace build
3. Verify no compilation errors
4. Verify no "Cannot find type" errors

**Build commands:**
```bash
cd /Users/rroques/Desktop/GOMA/iOS/sportsbook-ios

# Clean build
xcodebuild clean -workspace Sportsbook.xcworkspace -scheme BetssonCameroonApp

# Full build
xcodebuild build -workspace Sportsbook.xcworkspace -scheme BetssonCameroonApp -destination 'platform=iOS Simulator,name=iPhone 16 Pro'
```

### Unit Tests

Run full test suite:
```bash
xcodebuild test -workspace Sportsbook.xcworkspace -scheme BetssonCameroonApp -destination 'platform=iOS Simulator,name=iPhone 16 Pro'
```

**Expected result:** All tests pass

**If tests fail:**
- Check for tests that import deleted connector classes
- Update test files to use EveryMatrixUnifiedConnector

### Integration Tests

**Smoke test checklist:**
- [ ] Login works
- [ ] Place bet works
- [ ] Get bet history works
- [ ] Cashout works
- [ ] Casino games load
- [ ] Recommendations display

**Environment:** Test in staging first, then production

---

## Documentation Updates

### Files to update:

**1. CLAUDE.md (if connectors are mentioned)**
- Remove references to old connector classes
- Update architecture diagrams

**2. API_DEVELOPMENT_GUIDE.md**
- Update examples to use EveryMatrixUnifiedConnector
- Remove references to creating new connector subclasses

**3. README files**
- Update ServicesProvider README
- Update EveryMatrix integration docs

**4. Architecture diagrams**
- Update to show unified connector architecture
- Remove old connector class diagrams

---

## Git Workflow

### Commit Strategy

**Commit 1: Remove feature flags**
```bash
git add Client.swift
git commit -m "Phase 4: Remove unified connector feature flags

All APIs migrated successfully. Feature flags no longer needed.

- Removed useUnifiedConnector_Recsys
- Removed useUnifiedConnector_OddsMatrix
- Removed useUnifiedConnector_PlayerAPI
- Removed useUnifiedConnector_Casino"
```

**Commit 2: Delete legacy connectors**
```bash
git rm EveryMatrixOddsMatrixAPIConnector.swift
git rm EveryMatrixPlayerAPIConnector.swift
git rm EveryMatrixCasinoConnector.swift
git rm EveryMatrixRecsysAPIConnector.swift

git commit -m "Phase 4: Delete legacy connector classes

Replaced by EveryMatrixUnifiedConnector with API type enum.

Deleted files:
- EveryMatrixOddsMatrixAPIConnector.swift (24 lines)
- EveryMatrixPlayerAPIConnector.swift (35 lines)
- EveryMatrixCasinoConnector.swift (43 lines)
- EveryMatrixRecsysAPIConnector.swift (23 lines)

Total: ~125 lines deleted"
```

**Commit 3: Update type annotations**
```bash
git add EveryMatrixBettingProvider.swift
git add EveryMatrixPrivilegedAccessManager.swift
git add EveryMatrixCasinoProvider.swift
git add EveryMatrixProvider.swift

git commit -m "Phase 4: Update connector type annotations

Changed connector types from legacy classes to unified connector.

Updated:
- EveryMatrixBettingProvider
- EveryMatrixPrivilegedAccessManager
- EveryMatrixCasinoProvider
- EveryMatrixProvider"
```

**Commit 4: Update documentation**
```bash
git add Documentation/
git commit -m "Phase 4: Update documentation for unified connector

Removed references to legacy connector classes.
Updated architecture diagrams and examples."
```

---

## Verification Checklist

Before declaring Phase 4 complete:

### Code Verification
- [ ] All 4 legacy connector files deleted
- [ ] All feature flags removed from Client.swift
- [ ] No remaining imports of deleted classes
- [ ] Type annotations updated
- [ ] No compilation errors
- [ ] No compiler warnings about unused code

### Testing Verification
- [ ] All unit tests pass
- [ ] All integration tests pass
- [ ] Smoke tests pass in staging
- [ ] Smoke tests pass in production

### Documentation Verification
- [ ] CLAUDE.md updated
- [ ] Architecture docs updated
- [ ] API development guide updated
- [ ] Migration docs archived

### Git Verification
- [ ] All changes committed
- [ ] Commit messages clear and descriptive
- [ ] Code review completed
- [ ] Branch merged to main

---

## Success Criteria

After Phase 4 is complete:

✅ **All legacy connector classes deleted**
✅ **All feature flags removed**
✅ **Code compiles without errors**
✅ **All tests pass**
✅ **Production is stable**
✅ **Documentation updated**
✅ **~185 total lines of code deleted**
✅ **Architecture simplified**
✅ **Easier to add new APIs in future**

---

## Rollback Plan

### If issues discovered after Phase 4:

**Option 1: Revert commits**
```bash
# Find commit hash before Phase 4
git log --oneline

# Revert to that commit
git revert <commit-hash>

# Push revert
git push origin main
```

**Option 2: Restore deleted files**
```bash
# Restore from git history
git checkout <previous-commit> -- EveryMatrixOddsMatrixAPIConnector.swift
git checkout <previous-commit> -- EveryMatrixPlayerAPIConnector.swift
git checkout <previous-commit> -- EveryMatrixCasinoConnector.swift
git checkout <previous-commit> -- EveryMatrixRecsysAPIConnector.swift

# Re-add feature flags
# Restore conditional logic
```

**Risk is LOW because:**
- Migration was already tested in Phase 3
- Phase 4 is just cleanup
- All code was working before deletion

---

## Common Issues & Solutions

### Issue 1: Compilation Error - Cannot Find Type

**Symptoms:**
- "Cannot find type 'EveryMatrixOddsMatrixAPIConnector'"
- Build fails after deletion

**Diagnosis:**
- Some file still imports or references deleted class

**Solution:**
- Search codebase for class name
- Update type annotations
- Remove unused imports

### Issue 2: Tests Fail After Deletion

**Symptoms:**
- Unit tests reference deleted classes
- Mock implementations don't compile

**Diagnosis:**
- Test files import deleted connectors

**Solution:**
- Update test files to use EveryMatrixUnifiedConnector
- Update mock implementations

### Issue 3: Merge Conflicts

**Symptoms:**
- Git conflicts when merging Phase 4 branch

**Diagnosis:**
- Other developers modified same files

**Solution:**
- Resolve conflicts carefully
- Prefer unified connector in conflicts
- Re-run tests after resolution

---

## Final Notes

### What Was Achieved

**Before Migration:**
- 4 separate connector subclasses
- Hardcoded Casino auth logic in base class
- 150+ lines of duplicated code
- Difficult to add new APIs

**After Migration:**
- 1 unified connector class
- Pluggable authentication strategies
- API type enum for configuration
- Easy to add new APIs (just add enum case)

### Code Quality Improvements

✅ **Open/Closed Principle:** Can add new APIs without modifying existing code
✅ **Single Responsibility:** Each strategy handles one auth type
✅ **Dependency Injection:** All connectors are injectable
✅ **Testability:** Easy to mock and test
✅ **Maintainability:** Less code, clearer structure

### Future Enhancements

**Potential improvements:**
1. Add protocol for connector interface (enable better mocking)
2. Extract base URL configuration into separate service
3. Add connection pooling/caching
4. Implement retry strategies beyond authentication
5. Add circuit breaker pattern for failing APIs

**But for now:** Architecture is clean, tested, and production-ready.

---

## Migration Complete! 🎉

All 4 phases completed:
- ✅ Phase 1: Authentication strategy pattern
- ✅ Phase 2: Unified connector created
- ✅ Phase 3: All providers migrated
- ✅ Phase 4: Legacy code cleaned up

**Total impact:**
- ~185 lines deleted
- Architecture simplified
- Easier to maintain
- Ready for future APIs

**Next steps:**
- Monitor production for 2 weeks
- Archive migration documentation
- Close related tickets/issues
- Celebrate successful refactor! 🚀
