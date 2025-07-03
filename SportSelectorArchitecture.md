# Sport Selector Architecture

## Overview
This document visualizes the architecture of the Sport Selector feature, showing dependencies, data flow, and action sequences.

## Component Dependencies

```mermaid
graph TB
    subgraph "UI Layer"
        IVC[InPlayEventsViewController]
        NVC[NextUpEventsViewController]
        STSVC[SportTypeSelectorViewController]
        STSV[SportTypeSelectorView]
        STSIV[SportTypeSelectorItemView]
    end
    
    subgraph "ViewModel Layer"
        IVM[InPlayEventsViewModel]
        NVM[NextUpEventsViewModel]
        SSM[SportSelectorViewModel]
        PSM[PillSelectorBarViewModel]
    end
    
    subgraph "Data Layer"
        STS[SportTypeStore]
        ENV[Env.sportsStore]
    end
    
    subgraph "Models"
        S[Sport]
        STD[SportTypeData]
    end
    
    %% ViewControllers to ViewModels
    IVC --> IVM
    NVC --> NVM
    IVC -.->|creates on-demand| SSM
    NVC -.->|creates on-demand| SSM
    
    %% Sport Selector UI hierarchy
    STSVC --> STSV
    STSV --> STSIV
    STSVC --> SSM
    
    %% ViewModels to Services
    SSM --> STS
    STS --> ENV
    IVM --> PSM
    NVM --> PSM
    
    %% Data relationships
    SSM --> S
    SSM --> STD
    S -.->|converts to| STD
    
    style IVC fill:#e1f5fe
    style NVC fill:#e1f5fe
    style STSVC fill:#e1f5fe
    style IVM fill:#c5e1a5
    style NVM fill:#c5e1a5
    style SSM fill:#c5e1a5
    style STS fill:#ffe0b2
    style S fill:#f8bbd0
    style STD fill:#f8bbd0
```

## Data Flow - Sport Selection

```mermaid
sequenceDiagram
    participant U as User
    participant STSIV as SportTypeSelectorItemView
    participant STSV as SportTypeSelectorView
    participant STSVC as SportTypeSelectorViewController
    participant SSM as SportSelectorViewModel
    participant STS as SportTypeStore
    participant IVC as InPlayEventsViewController
    participant IVM as InPlayEventsViewModel
    participant PSM as PillSelectorBarViewModel
    
    Note over SSM,STS: Initialization Phase
    SSM->>STS: getActiveSports()
    STS-->>SSM: [Sport] objects
    SSM->>SSM: Convert to [SportTypeData]
    SSM->>SSM: Store in originalSportsMap
    
    Note over U,STSIV: User Interaction Phase
    U->>STSIV: Tap sport item
    STSIV->>STSV: onSportSelected(SportTypeData)
    STSV->>STSVC: onSportSelected(SportTypeData)
    STSVC->>SSM: selectSport(SportTypeData)
    
    Note over SSM: Data Retrieval Phase
    SSM->>SSM: Lookup in originalSportsMap[id]
    SSM-->>SSM: Get full Sport object
    SSM->>SSM: onSportSelected callback
    
    Note over SSM,PSM: Update Phase
    SSM-->>IVC: Sport (via callback)
    IVC->>IVM: updateSportType(Sport)
    IVM->>PSM: updateCurrentSport(Sport)
    IVC->>STSVC: dismiss()
```

## Action Flow - Opening Sport Selector

```mermaid
flowchart LR
    subgraph "Trigger"
        U[User] -->|Taps sport pill| PSV[PillSelectorView]
    end
    
    subgraph "Propagation"
        PSV -->|selectPill 'sport_selector'| PSM[PillSelectorBarViewModel]
        PSM -->|onShowSportsSelector callback| IVC[InPlayEventsViewController]
    end
    
    subgraph "Creation"
        IVC -->|new| SSM[SportSelectorViewModel]
        IVC -->|new with viewModel| STSVC[SportTypeSelectorViewController]
        IVC -->|presentModally| STSVC
    end
```

## Data Model Transformation

```mermaid
graph LR
    subgraph "API Data"
        ST[SportType<br/>from ServicesProvider]
    end
    
    subgraph "App Model"
        S[Sport<br/>- id: String<br/>- name: String<br/>- alphaId: String?<br/>- numericId: String?<br/>- showEventCategory: Bool<br/>- liveEventsCount: Int<br/>- outrightEventsCount: Int<br/>- eventsCount: Int]
    end
    
    subgraph "UI Model"
        STD[SportTypeData<br/>- id: String<br/>- name: String<br/>- iconName: String]
    end
    
    ST -->|ServiceProviderModelMapper| S
    S -->|sportToSportTypeData| STD
    STD -->|selectSport lookup| S
    
    style ST fill:#ffe0b2
    style S fill:#c5e1a5
    style STD fill:#e1f5fe
```

## Lifecycle Management

```mermaid
stateDiagram-v2
    [*] --> PillTapped: User taps sport selector pill
    
    PillTapped --> CreateViewModel: presentSportsSelector()
    
    CreateViewModel --> LoadSports: SportSelectorViewModel.init()
    note right of LoadSports: Synchronous load via<br/>getActiveSports()
    
    LoadSports --> DisplayModal: SportTypeSelectorViewController<br/>presented
    
    DisplayModal --> SportSelected: User selects sport
    DisplayModal --> Cancelled: User cancels
    
    SportSelected --> UpdateSport: updateSportType(sport)
    UpdateSport --> DismissModal
    
    Cancelled --> DismissModal
    
    DismissModal --> Deallocated: ViewModel & VC<br/>deallocated
    
    Deallocated --> [*]
```

## Memory Management Strategy

```mermaid
graph TB
    subgraph "Old Approach ❌"
        direction TB
        PVM1[Parent ViewModel] -->|owns| SSM1[SportSelectorViewModel]
        SSM1 -->|subscribes to| PUB1[activeSportsPublisher]
        PUB1 -->|continuous updates| SSM1
        SSM1 -->|stores| MAP1[originalSportsMap]
        MAP1 -->|long-lived references| CRASH[Memory Corruption]
        
        style CRASH fill:#ff5252
    end
    
    subgraph "New Approach ✅"
        direction TB
        PVM2[Parent ViewModel] -.->|creates on-demand| SSM2[SportSelectorViewModel]
        SSM2 -->|synchronous call| GAS[getActiveSports()]
        GAS -->|immediate return| SSM2
        SSM2 -->|stores briefly| MAP2[originalSportsMap]
        MODAL[Modal Dismissed] -->|deallocates| SSM2
        
        style SSM2 fill:#66bb6a
        style MAP2 fill:#66bb6a
    end
```

## Key Architecture Decisions

### 1. On-Demand ViewModel Creation
- SportSelectorViewModel created only when modal is presented
- Automatically deallocated when modal is dismissed
- Prevents long-lived subscriptions and memory issues

### 2. Synchronous Data Loading
- Uses `getActiveSports()` instead of `activeSportsPublisher`
- No need for live updates in a modal context
- Eliminates memory corruption from subscription updates

### 3. Data Preservation Strategy
- `originalSportsMap` stores full Sport objects temporarily
- Safe because lifecycle is short (modal presentation duration)
- Preserves all Sport properties (alphaId, event counts, etc.)

### 4. Callback Chain
- ViewController handles UI callbacks (SportTypeData)
- ViewModel handles business logic (Sport)
- Clear separation of concerns between layers