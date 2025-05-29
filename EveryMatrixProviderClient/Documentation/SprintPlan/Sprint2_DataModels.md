# Sprint 2: Data Models & Mapping Layer

## Sprint Goal
Create comprehensive data models matching EveryMatrix API entities and implement transformation logic for data mapping.

## Duration: 1.5 weeks

## Epic 2.1: Core Entity Models (2 days)

### Task 2.1.1: Create Sport Model
- **File**: `Sources/Models/Sport.swift`
- **Description**: Sport entity with all properties from API
- **Acceptance Criteria**:
  - All properties from web implementation
  - Codable conformance
  - Equatable and Hashable
  - Context support (live/popular)
  - Virtual sports support

### Task 2.1.2: Create Location Model
- **File**: `Sources/Models/Location.swift`
- **Description**: Location/Region entity
- **Acceptance Criteria**:
  - Country/region properties
  - Event counts
  - Type identification
  - Context support

### Task 2.1.3: Create Event Model
- **File**: `Sources/Models/Event.swift`
- **Description**: Match/Tournament event model
- **Acceptance Criteria**:
  - Match properties (teams, scores, time)
  - Tournament properties
  - Live status handling
  - Parent relationships
  - Market/outcome collections

### Task 2.1.4: Create Market Model
- **File**: `Sources/Models/Market.swift`
- **Description**: Betting market model
- **Acceptance Criteria**:
  - Market properties (name, type, status)
  - Display properties
  - Asian handicap support
  - Market groups
  - Outcome relationships

### Task 2.1.5: Create Outcome Model
- **File**: `Sources/Models/Outcome.swift`
- **Description**: Betting outcome/selection model
- **Acceptance Criteria**:
  - Outcome properties
  - Multiple market support
  - Status handling
  - Betting offer relationship

### Task 2.1.6: Create BettingOffer Model
- **File**: `Sources/Models/BettingOffer.swift`
- **Description**: Odds/prices model
- **Acceptance Criteria**:
  - Odds in multiple formats
  - Status and availability
  - Last changed tracking
  - Provider information

## Epic 2.2: Supporting Models (1 day)

### Task 2.2.1: Create EventInfo Model
- **File**: `Sources/Models/EventInfo.swift`
- **Description**: Additional event information
- **Acceptance Criteria**:
  - Score information
  - Period/part information
  - Status details
  - Statistics support

### Task 2.2.2: Create MainMarket Model
- **File**: `Sources/Models/MainMarket.swift`
- **Description**: Main market types
- **Acceptance Criteria**:
  - Popular market identification
  - Sport-specific main markets
  - Live/pre-live distinction

### Task 2.2.3: Create MarketOutcomeRelation Model
- **File**: `Sources/Models/MarketOutcomeRelation.swift`
- **Description**: Market-to-outcome relationships
- **Acceptance Criteria**:
  - Many-to-many relationships
  - Efficient lookup support

## Epic 2.3: Mapper Implementation (2 days)

### Task 2.3.1: Create Sport Mapper
- **File**: `Sources/Mappers/SportMapper.swift`
- **Description**: Transform raw API data to Sport models
- **Acceptance Criteria**:
  - Handle all sport properties
  - Context-aware mapping
  - Merge with existing data
  - Icon ID generation

### Task 2.3.2: Create Event Mapper
- **File**: `Sources/Mappers/EventMapper.swift`
- **Description**: Transform events with relationships
- **Acceptance Criteria**:
  - Map all event types
  - Attach markets and outcomes
  - Handle live data
  - Score parsing

### Task 2.3.3: Create Market/Outcome Mapper
- **File**: `Sources/Mappers/MarketOutcomeMapper.swift`
- **Description**: Transform markets and outcomes
- **Acceptance Criteria**:
  - Bidirectional relationships
  - Group handling
  - Display name generation
  - Asian line support

### Task 2.3.4: Create Relationship Builder
- **File**: `Sources/Mappers/RelationshipBuilder.swift`
- **Description**: Build entity relationships
- **Acceptance Criteria**:
  - Efficient relationship building
  - Handle orphaned entities
  - Maintain referential integrity

## Epic 2.4: Data Transformation Utilities (1.5 days)

### Task 2.4.1: Create Response Builder
- **File**: `Sources/Utilities/ResponseBuilder.swift`
- **Description**: Build structured responses from raw data
- **Acceptance Criteria**:
  - Match web's buildResponse logic
  - Chunk by entity type
  - Array wrapping options
  - Version handling

### Task 2.4.2: Implement Entity Chunking
- **File**: `Sources/Utilities/EntityChunker.swift`
- **Description**: Group entities by type
- **Acceptance Criteria**:
  - Efficient chunking algorithm
  - Preserve order
  - Handle mixed entity types

### Task 2.4.3: Create Update Merger
- **File**: `Sources/Utilities/UpdateMerger.swift`
- **Description**: Merge incremental updates
- **Acceptance Criteria**:
  - Handle CREATE/UPDATE/DELETE
  - Property-level updates
  - Conflict resolution
  - Performance optimization

## Epic 2.5: Type System & Protocols (1 day)

### Task 2.5.1: Define Entity Protocol
- **File**: `Sources/Protocols/EntityProtocol.swift`
- **Description**: Common protocol for all entities
- **Acceptance Criteria**:
  - Entity type identification
  - ID management
  - Version tracking
  - Change tracking

### Task 2.5.2: Create Type Aliases
- **File**: `Sources/Core/TypeAliases.swift`
- **Description**: Common type definitions
- **Acceptance Criteria**:
  - Entity ID types
  - Timestamp types
  - Collection types
  - Closure types

## Deliverables
1. Complete data model hierarchy
2. Comprehensive mapping system
3. Relationship management
4. Update merging logic
5. Unit tests for all models and mappers

## Definition of Done
- [ ] All models match web implementation
- [ ] Codable tests for all models
- [ ] Mapper tests with real data samples
- [ ] Performance benchmarks for large datasets
- [ ] Documentation with model diagrams
- [ ] No force unwrapping in mappers 