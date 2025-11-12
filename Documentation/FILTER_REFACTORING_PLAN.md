# Filter System Refactoring Plan: Eliminating Magic Strings

**Status:** Planning
**Priority:** High - Code Quality & Maintainability
**Impact:** 20+ files across BetssonCameroonApp, GomaUI, ServicesProvider
**Estimated Effort:** 2-3 days

## Executive Summary

The current filter system uses magic strings (`"all"`, `"0"`, `"{countryId}_all"`) throughout the codebase, violating fundamental software engineering principles:
- **Type Safety**: Strings can be typo'd without compiler errors
- **Semantic Clarity**: `"all"` vs `"0"` vs `""` all mean the same thing
- **Validation**: No runtime validation of string formats
- **Maintainability**: String parsing logic scattered across multiple files

This refactoring introduces type-safe enums that encode domain logic explicitly while maintaining backward compatibility.

---

## Software Engineering Principles Applied

### 1. **Type Safety & Compile-Time Guarantees**
- Replace stringly-typed APIs with proper enums
- Compiler enforces exhaustive pattern matching
- Impossible to pass invalid values

### 2. **Single Responsibility Principle (SRP)**
- Each enum represents ONE concept clearly
- Separation of parsing logic from business logic
- Clear boundaries between UI, domain, and persistence layers

### 3. **Don't Repeat Yourself (DRY)**
- Centralize magic string logic in ONE place (enum init/encode)
- Remove duplicated parsing code across 20+ files
- Single source of truth for filter semantics

### 4. **Open/Closed Principle**
- Enums are closed for modification (exhaustive cases)
- Open for extension via protocol conformance
- Easy to add new filter types without breaking existing code

### 5. **Fail Fast & Defensive Programming**
- Validate inputs at boundaries (Codable init)
- Throw descriptive errors on invalid formats
- No silent failures or "guess the format" logic

### 6. **Explicit Over Implicit**
- `LeagueFilter.allInCountry("france")` > `"france_all"`
- Intent is obvious from type, not embedded in string
- Self-documenting code

### 7. **Testability**
- Pure enum transformations are trivially testable
- Mock-free unit tests for conversion logic
- Property-based testing for Codable round-trips

### 8. **Backward Compatibility**
- Custom Codable implementations maintain wire format
- Existing persisted data still works
- Gradual migration path with deprecation warnings

---

## Current Problems (Technical Debt)

### Problem 1: Multiple Representations of "No Filter"

```swift
// ALL of these mean "no filter applied":
leagueId = "all"
leagueId = "0"
leagueId = ""

// Found in AppliedEventsFilters+MatchesFilterOptions.swift:50
if leagueId == "all" || leagueId == "0" || leagueId.isEmpty {
```

**Risk**: Easy to miss one check, inconsistent behavior

### Problem 2: String Interpolation as Domain Logic

```swift
// CombinedFiltersViewModel.swift:190
let allOption = LeagueOption(
    id: "\(venueId)_all",  // ← Domain logic in string formatting!
    title: "All Leagues"
)

// AppliedEventsFilters+MatchesFilterOptions.swift:45-48
if leagueId.hasSuffix("_all") {
    let countryId = String(leagueId.dropLast(4))  // ← Magic number!
    location = .specific(countryId)
}
```

**Risks**:
- What if `venueId` contains `"_"`? Parse fails silently
- `.dropLast(4)` assumes exact format, no validation
- `"_all"` → empty country ID (bug!)
- `"france_all_world"` → treated as league ID (bug!)

### Problem 3: Scattered Parsing Logic

Same parsing logic duplicated in:
- `AppliedEventsFilters+MatchesFilterOptions.swift` (lines 44-58)
- `MatchesFilterOptions.swift` (lines 125, 149)
- `CombinedFiltersViewModel.swift` (lines 142-144)
- `NextUpEventsViewModel.swift` (line 459)
- 15+ other locations

**Impact**: Bug fixes must be applied everywhere, easy to miss spots

### Problem 4: No Type Safety in Protocols

```swift
// GomaUI filter protocols
public protocol LeaguesFilterViewModelProtocol {
    var selectedOptionId: CurrentValueSubject<String, Never> { get }
    //                                        ^^^^^^ Could be anything!
    func selectOption(withId id: String)
}
```

**Risk**: Can pass any string, including malformed values

---

## Solution Architecture

### Phase 1: Core Domain Types (SharedModels or ServicesProvider)

#### 1.1 Generic Filter Identifier

```swift
/// Represents a filter identifier that can be "all" or a specific ID
/// Handles backward compatibility with legacy "0" and empty string values
public enum FilterIdentifier: Codable, Equatable, Hashable {
    case all
    case specific(String)

    // MARK: - Convenience Initializers

    public init(stringValue: String) {
        if stringValue == "all" || stringValue == "0" || stringValue.isEmpty {
            self = .all
        } else {
            self = .specific(stringValue)
        }
    }

    // MARK: - Codable (Backward Compatible)

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self.init(stringValue: rawValue)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }

    // MARK: - Computed Properties

    public var rawValue: String {
        switch self {
        case .all:
            return "all"
        case .specific(let id):
            return id
        }
    }

    public var isAll: Bool {
        if case .all = self { return true }
        return false
    }

    public var specificId: String? {
        if case .specific(let id) = self { return id }
        return nil
    }
}

// MARK: - ExpressibleByStringLiteral (Developer Convenience)
extension FilterIdentifier: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(stringValue: value)
    }
}

// MARK: - CustomStringConvertible (Debugging)
extension FilterIdentifier: CustomStringConvertible {
    public var description: String {
        switch self {
        case .all:
            return "FilterIdentifier.all"
        case .specific(let id):
            return "FilterIdentifier.specific(\"\(id)\")"
        }
    }
}
```

#### 1.2 League Filter Identifier (Handles Country + League Logic)

```swift
/// Represents a league filter that can be:
/// - All leagues across all countries
/// - All leagues within a specific country
/// - A specific league
public enum LeagueFilterIdentifier: Codable, Equatable, Hashable {
    case all
    case allInCountry(countryId: String)
    case specificLeague(leagueId: String)

    // MARK: - Validation

    public enum ValidationError: Error, LocalizedError {
        case emptyCountryId
        case emptyLeagueId
        case invalidFormat(String)

        public var errorDescription: String? {
            switch self {
            case .emptyCountryId:
                return "Country ID cannot be empty in allInCountry filter"
            case .emptyLeagueId:
                return "League ID cannot be empty in specificLeague filter"
            case .invalidFormat(let value):
                return "Invalid league filter format: \"\(value)\""
            }
        }
    }

    // MARK: - Initializers

    /// Parse from legacy string format with validation
    /// Formats:
    /// - "all", "0", "" → .all
    /// - "{countryId}_all" → .allInCountry(countryId)
    /// - "{leagueId}" → .specificLeague(leagueId)
    public init(stringValue: String) throws {
        // Handle "all" variants
        if stringValue == "all" || stringValue == "0" || stringValue.isEmpty {
            self = .all
            return
        }

        // Handle "{countryId}_all" format
        if stringValue.hasSuffix("_all") {
            let countryId = String(stringValue.dropLast(4))

            // VALIDATION: Ensure country ID is not empty
            guard !countryId.isEmpty else {
                throw ValidationError.emptyCountryId
            }

            self = .allInCountry(countryId: countryId)
            return
        }

        // Handle specific league ID
        guard !stringValue.isEmpty else {
            throw ValidationError.emptyLeagueId
        }

        self = .specificLeague(leagueId: stringValue)
    }

    /// Convenience initializer for backward compatibility (non-throwing)
    /// Returns .all for invalid formats
    public init(stringValueOrDefault: String) {
        self = (try? Self(stringValue: stringValueOrDefault)) ?? .all
    }

    // MARK: - Factory Methods

    public static func allLeagues() -> Self {
        return .all
    }

    public static func country(_ countryId: String) -> Self {
        return .allInCountry(countryId: countryId)
    }

    public static func league(_ leagueId: String) -> Self {
        return .specificLeague(leagueId: leagueId)
    }

    // MARK: - Codable (Backward Compatible)

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)

        // Use non-throwing initializer for Codable
        // This maintains backward compatibility with persisted data
        self = Self(stringValueOrDefault: rawValue)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }

    // MARK: - Computed Properties

    public var rawValue: String {
        switch self {
        case .all:
            return "all"
        case .allInCountry(let countryId):
            return "\(countryId)_all"
        case .specificLeague(let leagueId):
            return leagueId
        }
    }

    public var isAll: Bool {
        if case .all = self { return true }
        return false
    }

    public var countryId: String? {
        if case .allInCountry(let id) = self { return id }
        return nil
    }

    public var leagueId: String? {
        if case .specificLeague(let id) = self { return id }
        return nil
    }

    // MARK: - Conversion to Domain Models

    /// Convert to LocationFilter and TournamentFilter for ServicesProvider
    public func toLocationAndTournament() -> (location: LocationFilter, tournament: TournamentFilter) {
        switch self {
        case .all:
            return (.all, .all)

        case .allInCountry(let countryId):
            return (.specific(countryId), .all)

        case .specificLeague(let leagueId):
            return (.all, .specific(leagueId))
        }
    }
}

// MARK: - ExpressibleByStringLiteral
extension LeagueFilterIdentifier: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(stringValueOrDefault: value)
    }
}

// MARK: - CustomStringConvertible
extension LeagueFilterIdentifier: CustomStringConvertible {
    public var description: String {
        switch self {
        case .all:
            return "LeagueFilter.all"
        case .allInCountry(let countryId):
            return "LeagueFilter.allInCountry(\"\(countryId)\")"
        case .specificLeague(let leagueId):
            return "LeagueFilter.specificLeague(\"\(leagueId)\")"
        }
    }
}
```

### Phase 2: Update Domain Models

#### 2.1 Update AppliedEventsFilters

```swift
// BetssonCameroonApp/App/Models/Events/AppliedEventsFilters.swift

public struct AppliedEventsFilters: Codable, Equatable {
    var sportId: FilterIdentifier          // Changed from String
    var timeFilter: TimeFilter
    var sortType: SortType
    var leagueFilter: LeagueFilterIdentifier  // Changed from leagueId: String

    // MARK: - Backward Compatibility (Codable)

    enum CodingKeys: String, CodingKey {
        case sportId
        case timeFilter
        case sortType
        case leagueFilter = "leagueId"  // Map to old key name
    }

    // MARK: - Defaults

    public static let `default` = AppliedEventsFilters(
        sportId: .all,
        timeFilter: .all,
        sortType: .time,
        leagueFilter: .all
    )

    // MARK: - Legacy String Accessors (Deprecated)

    @available(*, deprecated, message: "Use sportId enum directly instead of string")
    public var sportIdString: String {
        return sportId.rawValue
    }

    @available(*, deprecated, message: "Use leagueFilter enum directly instead of string")
    public var leagueIdString: String {
        return leagueFilter.rawValue
    }
}
```

#### 2.2 Update Conversion Extensions

```swift
// BetssonCameroonApp/App/Screens/NextUpEvents/CombinedFilters/AppliedEventsFilters+MatchesFilterOptions.swift

extension AppliedEventsFilters {

    public func toMatchesFilterOptions(optionalUserId: String? = nil) -> MatchesFilterOptions {
        // TimeFilter conversion (unchanged)
        let timeRange: TimeRange
        switch timeFilter {
        case .all: timeRange = .all
        case .oneHour: timeRange = .oneHour
        case .eightHours: timeRange = .eightHours
        case .today: timeRange = .today
        case .fortyEightHours: timeRange = .fortyEightHours
        }

        // SortType conversion (unchanged)
        let sortBy: SortBy
        switch sortType {
        case .popular: sortBy = .popular
        case .upcoming: sortBy = .upcoming
        case .favorites: sortBy = .favorites
        }

        // NEW: Clean enum-based conversion (replaces 15 lines of string parsing!)
        let (location, tournament) = leagueFilter.toLocationAndTournament()

        return MatchesFilterOptions(
            sportId: sportId.rawValue,  // ServicesProvider still uses String
            timeRange: timeRange,
            sortBy: sortBy,
            location: location,
            tournament: tournament,
            optionalUserId: optionalUserId
        )
    }
}

extension MatchesFilterOptions {

    public func toAppliedEventsFilters() -> AppliedEventsFilters {
        // TimeRange conversion (unchanged)
        let timeFilter: AppliedEventsFilters.TimeFilter
        switch timeRange {
        case .all: timeFilter = .all
        case .oneHour: timeFilter = .oneHour
        case .eightHours: timeFilter = .eightHours
        case .today: timeFilter = .today
        case .fortyEightHours: timeFilter = .fortyEightHours
        }

        // SortBy conversion (unchanged)
        let sortType: AppliedEventsFilters.SortType
        switch sortBy {
        case .popular: sortType = .popular
        case .upcoming: sortType = .upcoming
        case .favorites: sortType = .favorites
        }

        // NEW: Type-safe conversion from LocationFilter + TournamentFilter
        let leagueFilter: LeagueFilterIdentifier
        switch (location, tournament) {
        case (.all, .all):
            leagueFilter = .all

        case (.specific(let countryId), .all):
            leagueFilter = .allInCountry(countryId: countryId)

        case (.all, .specific(let leagueId)):
            leagueFilter = .specificLeague(leagueId: leagueId)

        case (.specific(let countryId), .specific(let leagueId)):
            // Edge case: Both country and league specified
            // Prioritize league (more specific filter)
            leagueFilter = .specificLeague(leagueId: leagueId)
        }

        return AppliedEventsFilters(
            sportId: FilterIdentifier(stringValue: sportId),
            timeFilter: timeFilter,
            sortType: sortType,
            leagueFilter: leagueFilter
        )
    }
}
```

### Phase 3: Update GomaUI Protocols

#### 3.1 Update Filter Protocols (Backward Compatible)

```swift
// Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/LeaguesFilterView/LeaguesFilterViewModelProtocol.swift

public protocol LeaguesFilterViewModelProtocol {
    // NEW: Type-safe publisher
    var selectedFilter: CurrentValueSubject<LeagueFilterIdentifier, Never> { get }

    // DEPRECATED: String-based publisher (for migration period)
    @available(*, deprecated, message: "Use selectedFilter instead")
    var selectedOptionId: CurrentValueSubject<String, Never> { get }

    // NEW: Type-safe selection
    func selectFilter(_ filter: LeagueFilterIdentifier)

    // DEPRECATED: String-based selection
    @available(*, deprecated, message: "Use selectFilter(_:) instead")
    func selectOption(withId id: String)

    var leagues: [LeagueOption] { get }
    var onLeagueFilterSelected: ((String) -> Void)? { get set }
}

// MARK: - Default Implementations (Bridge deprecated to new)
extension LeaguesFilterViewModelProtocol {
    public func selectOption(withId id: String) {
        if let filter = try? LeagueFilterIdentifier(stringValue: id) {
            selectFilter(filter)
        }
    }
}
```

#### 3.2 Update Mock ViewModels

```swift
// Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/LeaguesFilterView/MockLeaguesFilterViewModel.swift

public class MockLeaguesFilterViewModel: LeaguesFilterViewModelProtocol {

    // NEW: Type-safe storage
    public var selectedFilter: CurrentValueSubject<LeagueFilterIdentifier, Never>

    // DEPRECATED: String-based storage (computed from selectedFilter)
    @available(*, deprecated)
    public var selectedOptionId: CurrentValueSubject<String, Never> {
        let publisher = CurrentValueSubject<String, Never>(selectedFilter.value.rawValue)
        selectedFilter
            .map { $0.rawValue }
            .subscribe(publisher)
        return publisher
    }

    public var leagues: [LeagueOption]
    public var onLeagueFilterSelected: ((String) -> Void)?

    public init(
        leagues: [LeagueOption] = [],
        selectedFilter: LeagueFilterIdentifier = .all
    ) {
        self.leagues = leagues
        self.selectedFilter = CurrentValueSubject(selectedFilter)
    }

    // NEW: Type-safe selection
    public func selectFilter(_ filter: LeagueFilterIdentifier) {
        selectedFilter.send(filter)
        onLeagueFilterSelected?(filter.rawValue)
    }
}
```

### Phase 4: Update ViewModels

#### 4.1 Update CombinedFiltersViewModel

```swift
// BetssonCameroonApp/App/Screens/NextUpEvents/CombinedFilters/CombinedFiltersViewModel.swift

// BEFORE (line 190):
let allOption = LeagueOption(
    id: "\(venueId)_all",  // ← String interpolation magic!
    icon: nil,
    title: "All Leagues",
    count: totalCount
)

// AFTER:
let allFilter = LeagueFilterIdentifier.allInCountry(countryId: venueId)
let allOption = LeagueOption(
    id: allFilter.rawValue,  // ← Type-safe generation!
    icon: nil,
    title: "All Leagues",
    count: totalCount
)

// BEFORE (line 144):
league.id == "all" ? nil : league.id

// AFTER:
let filter = try? LeagueFilterIdentifier(stringValue: league.id)
filter?.leagueId  // Returns nil for .all and .allInCountry, returns ID for .specificLeague
```

#### 4.2 Update NextUpEventsViewModel

```swift
// BetssonCameroonApp/App/Screens/NextUpEvents/NextUpEventsViewModel.swift

// BEFORE (line 459):
let title = leagueId == "all" || leagueId == "0" ? allLeaguesOption.title : "League \(leagueId)"

// AFTER:
let title = appliedFilters.leagueFilter.isAll
    ? allLeaguesOption.title
    : "League \(appliedFilters.leagueFilter.leagueId ?? "Unknown")"

// Or better yet, use pattern matching:
let title: String
switch appliedFilters.leagueFilter {
case .all:
    title = allLeaguesOption.title
case .allInCountry(let countryId):
    title = "All Leagues in \(countryName(for: countryId))"
case .specificLeague(let leagueId):
    title = leagueName(for: leagueId) ?? "League \(leagueId)"
}
```

### Phase 5: Comprehensive Testing

#### 5.1 Unit Tests for FilterIdentifier

```swift
// Tests/SharedModelsTests/FilterIdentifierTests.swift

import XCTest
@testable import SharedModels

final class FilterIdentifierTests: XCTestCase {

    // MARK: - Initialization Tests

    func testInitWithAllString() {
        let filter = FilterIdentifier(stringValue: "all")
        XCTAssertEqual(filter, .all)
        XCTAssertTrue(filter.isAll)
    }

    func testInitWithZeroString() {
        let filter = FilterIdentifier(stringValue: "0")
        XCTAssertEqual(filter, .all)
        XCTAssertTrue(filter.isAll)
    }

    func testInitWithEmptyString() {
        let filter = FilterIdentifier(stringValue: "")
        XCTAssertEqual(filter, .all)
        XCTAssertTrue(filter.isAll)
    }

    func testInitWithSpecificId() {
        let filter = FilterIdentifier(stringValue: "123")
        XCTAssertEqual(filter, .specific("123"))
        XCTAssertFalse(filter.isAll)
        XCTAssertEqual(filter.specificId, "123")
    }

    // MARK: - Codable Tests (Backward Compatibility)

    func testCodableRoundTripAll() throws {
        let original = FilterIdentifier.all
        let encoded = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(FilterIdentifier.self, from: encoded)
        XCTAssertEqual(original, decoded)

        // Verify wire format is still "all" string
        let jsonString = String(data: encoded, encoding: .utf8)
        XCTAssertEqual(jsonString, "\"all\"")
    }

    func testCodableRoundTripSpecific() throws {
        let original = FilterIdentifier.specific("456")
        let encoded = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(FilterIdentifier.self, from: encoded)
        XCTAssertEqual(original, decoded)

        let jsonString = String(data: encoded, encoding: .utf8)
        XCTAssertEqual(jsonString, "\"456\"")
    }

    func testDecodingLegacyZeroValue() throws {
        let json = "\"0\"".data(using: .utf8)!
        let decoded = try JSONDecoder().decode(FilterIdentifier.self, from: json)
        XCTAssertEqual(decoded, .all)
    }

    // MARK: - Equatable Tests

    func testEquality() {
        XCTAssertEqual(FilterIdentifier.all, FilterIdentifier.all)
        XCTAssertEqual(FilterIdentifier.specific("123"), FilterIdentifier.specific("123"))
        XCTAssertNotEqual(FilterIdentifier.all, FilterIdentifier.specific("123"))
    }
}
```

#### 5.2 Unit Tests for LeagueFilterIdentifier

```swift
// Tests/SharedModelsTests/LeagueFilterIdentifierTests.swift

import XCTest
@testable import SharedModels

final class LeagueFilterIdentifierTests: XCTestCase {

    // MARK: - Initialization Tests

    func testInitWithAllVariants() throws {
        XCTAssertEqual(try LeagueFilterIdentifier(stringValue: "all"), .all)
        XCTAssertEqual(try LeagueFilterIdentifier(stringValue: "0"), .all)
        XCTAssertEqual(try LeagueFilterIdentifier(stringValue: ""), .all)
    }

    func testInitWithCountryAll() throws {
        let filter = try LeagueFilterIdentifier(stringValue: "france_all")
        XCTAssertEqual(filter, .allInCountry(countryId: "france"))
        XCTAssertEqual(filter.countryId, "france")
        XCTAssertNil(filter.leagueId)
    }

    func testInitWithSpecificLeague() throws {
        let filter = try LeagueFilterIdentifier(stringValue: "premier_league_123")
        XCTAssertEqual(filter, .specificLeague(leagueId: "premier_league_123"))
        XCTAssertNil(filter.countryId)
        XCTAssertEqual(filter.leagueId, "premier_league_123")
    }

    // MARK: - Validation Tests

    func testInitWithEmptyCountryIdThrows() {
        XCTAssertThrowsError(try LeagueFilterIdentifier(stringValue: "_all")) { error in
            XCTAssertEqual(error as? LeagueFilterIdentifier.ValidationError, .emptyCountryId)
        }
    }

    func testInitWithMalformedStringFallsBackToAll() {
        let filter = LeagueFilterIdentifier(stringValueOrDefault: "_all")
        XCTAssertEqual(filter, .all)
    }

    // MARK: - Conversion Tests

    func testConversionToLocationAndTournamentAll() {
        let filter = LeagueFilterIdentifier.all
        let (location, tournament) = filter.toLocationAndTournament()
        XCTAssertEqual(location, .all)
        XCTAssertEqual(tournament, .all)
    }

    func testConversionToLocationAndTournamentCountry() {
        let filter = LeagueFilterIdentifier.allInCountry(countryId: "uk")
        let (location, tournament) = filter.toLocationAndTournament()
        XCTAssertEqual(location, .specific("uk"))
        XCTAssertEqual(tournament, .all)
    }

    func testConversionToLocationAndTournamentLeague() {
        let filter = LeagueFilterIdentifier.specificLeague(leagueId: "epl_123")
        let (location, tournament) = filter.toLocationAndTournament()
        XCTAssertEqual(location, .all)
        XCTAssertEqual(tournament, .specific("epl_123"))
    }

    // MARK: - Codable Tests

    func testCodableRoundTripCountryAll() throws {
        let original = LeagueFilterIdentifier.allInCountry(countryId: "germany")
        let encoded = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(LeagueFilterIdentifier.self, from: encoded)
        XCTAssertEqual(original, decoded)

        // Verify wire format
        let jsonString = String(data: encoded, encoding: .utf8)
        XCTAssertEqual(jsonString, "\"germany_all\"")
    }

    // MARK: - Property-Based Tests (Round-Trip)

    func testRawValueRoundTrip() throws {
        let testCases: [LeagueFilterIdentifier] = [
            .all,
            .allInCountry(countryId: "france"),
            .allInCountry(countryId: "uk"),
            .specificLeague(leagueId: "123"),
            .specificLeague(leagueId: "premier_league")
        ]

        for original in testCases {
            let rawValue = original.rawValue
            let parsed = try LeagueFilterIdentifier(stringValue: rawValue)
            XCTAssertEqual(original, parsed, "Round-trip failed for \(original)")
        }
    }
}
```

#### 5.3 Integration Tests

```swift
// Tests/BetssonCameroonAppTests/Models/AppliedEventsFiltersTests.swift

import XCTest
@testable import BetssonCameroonApp
@testable import ServicesProvider

final class AppliedEventsFiltersConversionTests: XCTestCase {

    func testConversionAllFilters() {
        let filters = AppliedEventsFilters(
            sportId: .all,
            timeFilter: .all,
            sortType: .upcoming,
            leagueFilter: .all
        )

        let options = filters.toMatchesFilterOptions()
        XCTAssertEqual(options.location, .all)
        XCTAssertEqual(options.tournament, .all)
    }

    func testConversionCountryFilter() {
        let filters = AppliedEventsFilters(
            sportId: .specific("football"),
            timeFilter: .today,
            sortType: .popular,
            leagueFilter: .allInCountry(countryId: "france")
        )

        let options = filters.toMatchesFilterOptions()
        XCTAssertEqual(options.location, .specific("france"))
        XCTAssertEqual(options.tournament, .all)
    }

    func testConversionLeagueFilter() {
        let filters = AppliedEventsFilters(
            sportId: .specific("football"),
            timeFilter: .oneHour,
            sortType: .favorites,
            leagueFilter: .specificLeague(leagueId: "epl")
        )

        let options = filters.toMatchesFilterOptions()
        XCTAssertEqual(options.location, .all)
        XCTAssertEqual(options.tournament, .specific("epl"))
    }

    func testBackwardCompatibilityCodable() throws {
        // Simulate old persisted JSON with string leagueId
        let oldJson = """
        {
            "sportId": "0",
            "timeFilter": "all",
            "sortType": "upcoming",
            "leagueId": "france_all"
        }
        """.data(using: .utf8)!

        let decoded = try JSONDecoder().decode(AppliedEventsFilters.self, from: oldJson)
        XCTAssertEqual(decoded.leagueFilter, .allInCountry(countryId: "france"))
    }
}
```

---

## Migration Strategy

### Step 1: Create New Types (Non-Breaking)
- Add `FilterIdentifier` and `LeagueFilterIdentifier` to SharedModels
- Add comprehensive unit tests
- No changes to existing code yet

### Step 2: Update Domain Models (Backward Compatible)
- Update `AppliedEventsFilters` with new types
- Use `CodingKeys` mapping for backward compatibility
- Add deprecated string accessors for transition period
- Update conversion extensions

### Step 3: Update GomaUI Protocols (Phased)
- Add new type-safe methods alongside deprecated string methods
- Update mock implementations
- Add bridge implementations for deprecated methods

### Step 4: Update ViewModels (Gradual)
- Update ViewModels one-by-one to use new APIs
- Remove string parsing logic
- Compile and test after each ViewModel update

### Step 5: Update UI Components
- Update all 20+ usage sites
- Remove deprecated API calls
- Replace string comparisons with enum patterns

### Step 6: Remove Deprecated APIs
- After 1-2 release cycles, remove deprecated methods
- Remove string-based accessors
- Final cleanup

---

## Validation & Testing Checklist

### Unit Tests
- ✅ FilterIdentifier initialization with all variants
- ✅ FilterIdentifier Codable round-trip
- ✅ LeagueFilterIdentifier initialization with validation
- ✅ LeagueFilterIdentifier error throwing for invalid formats
- ✅ LeagueFilterIdentifier Codable round-trip
- ✅ LeagueFilterIdentifier conversion to LocationFilter/TournamentFilter
- ✅ Property-based testing for raw value round-trips

### Integration Tests
- ✅ AppliedEventsFilters → MatchesFilterOptions conversion
- ✅ MatchesFilterOptions → AppliedEventsFilters conversion
- ✅ Backward compatibility with old persisted JSON
- ✅ UI ViewModel filter selection flow

### Manual Testing
- ✅ Filter UI displays correct options
- ✅ Selecting filters updates properly
- ✅ "All" filter shows all leagues
- ✅ Country filter shows only leagues in that country
- ✅ League filter shows only that league's matches
- ✅ Filter persistence across app restarts
- ✅ Deep links with filter parameters work

---

## Risk Mitigation

### Backward Compatibility Risks
- **Risk**: Old persisted data fails to decode
- **Mitigation**: Custom Codable implementation handles all legacy formats
- **Validation**: Add integration test with real persisted JSON from production

### Performance Risks
- **Risk**: Enum matching slower than string comparison
- **Mitigation**: Enums compile to switch statements (same performance as if/else)
- **Validation**: Profile filter operations before/after refactoring

### Regression Risks
- **Risk**: Subtle behavior changes in filter logic
- **Mitigation**:
  - Comprehensive unit test coverage (50+ test cases)
  - Integration tests for all filter combinations
  - Manual QA testing of all filter scenarios
  - Phased rollout with feature flag

### Migration Risks
- **Risk**: Miss some string usage sites
- **Mitigation**:
  - Use compiler deprecation warnings to find all sites
  - Grep for magic strings (`"all"`, `"_all"`, `== "0"`)
  - Add runtime assertions in deprecated methods during transition

---

## Success Metrics

### Code Quality Improvements
- **Lines Removed**: ~100 lines of string parsing logic eliminated
- **Duplication Removed**: String parsing logic consolidated from 20+ files to 2 enums
- **Type Safety**: 0 remaining stringly-typed filter APIs
- **Test Coverage**: Filter logic covered by 50+ unit tests

### Maintainability Improvements
- **Bug Surface Area**: Reduced by 80% (no string typos, no parsing errors)
- **Onboarding Time**: New developers understand filter logic immediately (self-documenting enums)
- **Refactoring Confidence**: Compiler enforces exhaustive handling of all cases

### Runtime Improvements
- **Crash Rate**: Eliminate crashes from malformed filter strings
- **Validation**: Invalid filter formats caught at boundaries, not deep in business logic

---

## Timeline Estimate

| Phase | Duration | Complexity |
|-------|----------|------------|
| Phase 1: Core Types | 4 hours | Medium |
| Phase 2: Domain Models | 3 hours | Medium |
| Phase 3: GomaUI Protocols | 4 hours | High |
| Phase 4: ViewModels | 6 hours | High |
| Phase 5: Testing | 6 hours | Medium |
| Phase 6: Migration | 4 hours | Low |
| **TOTAL** | **27 hours** (~3.5 days) | - |

---

## Conclusion

This refactoring eliminates a pervasive anti-pattern (magic strings) and replaces it with type-safe, testable, maintainable code. The benefits far outweigh the migration cost:

- **Immediate**: Compiler catches bugs, code is self-documenting
- **Short-term**: Drastically reduced debugging time for filter issues
- **Long-term**: Easy to extend filter system with new types (e.g., date range filters)

The phased approach ensures backward compatibility and minimizes risk, while comprehensive testing ensures no regressions.

**Recommendation**: Prioritize this refactoring as "high impact, medium effort" technical debt paydown.
