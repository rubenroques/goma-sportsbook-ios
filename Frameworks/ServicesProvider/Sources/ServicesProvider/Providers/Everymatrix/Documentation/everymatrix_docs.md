# EveryMatrix Provider Architecture

## Overview

The EveryMatrix provider implementation follows a reactive, Redux-inspired architecture to handle WebSocket-based communication with the EveryMatrix sports betting platform. Unlike traditional REST-based backends, EveryMatrix primarily uses WebSockets for both data retrieval and real-time updates, requiring a specialized architecture to manage the normalized data stream and maintain a consistent application state.

## Core Components

### 1. Core Model Components

#### `EveryMatrix`
A namespace for EveryMatrix-specific types and constants. Contains enums for message types, change types, and entity types used in WebSocket communication.

#### `WebSocketMessageDTO<T>`
Generic container for messages received from the WebSocket. Contains version, format, message type, and an array of records of type T.

#### `ChangeRecordDTO<T>`
Represents a change to an entity, with a change type (CREATE, UPDATE, DELETE), entity type, ID, and optional changed properties.

#### `EmptyPayload`
An empty struct used for deletion operations where no additional data is needed.

### 2. Entity Management

#### `EMEntityProtocol`
Protocol that all DTO entities must conform to, requiring an ID property and a static entity type.

#### `SportDTO`, `MatchDTO`, etc.
Concrete DTO implementations for different entity types received from EveryMatrix. These contain the raw data fields directly mapped from the WebSocket messages.

#### `EMEntity`
A type-safe enum that can wrap any entity type (sport, match, etc.). Acts as a discriminated union to store different entity types in a single collection while maintaining type safety.

### 3. State Management

#### `EMAction`
Represents state changes as actions, similar to Redux. Three types:
- `insert(EMEntity)`: Add or replace an entity
- `delete(id: String, type: EntityType)`: Remove an entity
- `update(id: String, changes: [String: AnyCodable])`: Update an entity's properties

#### `TopicState`
Maintains the canonical in-memory state for a specific topic subscription. Stores entities in a normalized format (by ID) and provides type-safe accessors.

#### `reduce(state:action:)`
Pure function that applies an action to the current state to produce a new state.

#### `actions(from:)`
Function that converts WebSocket messages into a sequence of actions to be applied to the state.

### 4. Channel Management

#### `TopicSession`
An actor that manages state for a single WebSocket topic. Processes incoming messages, applies actions to the state, and publishes the updated entities.

#### `TopicManager`
Manages multiple topic sessions, handles message routing, and provides a facade for creating subscriptions.

### 5. Provider Implementation

#### `EveryMatrixConnector`
Handles the direct WebSocket connection, authentication, and message transport.

#### `EveryMatrixEventsProvider`
Implements the `EventsProvider` protocol, mapping between the app's domain requirements and the EveryMatrix-specific implementation.

#### Domain Mappers
Transform raw DTOs into domain models (e.g., `SportTypeMapper`, `EventsGroupMapper`). These separate the EveryMatrix-specific data format from the app's domain model.

## Interaction Flow

The components interact in a unidirectional data flow:

1. **EveryMatrixEventsProvider** receives a request for data (e.g., subscribeSportTypes())
2. **EveryMatrixConnector** establishes a WebSocket connection to the EveryMatrix backend
3. **TopicManager** creates or reuses a **TopicSession** for the requested topic
4. **TopicSession** processes messages through the **actions(from:)** and **reduce(state:action:)** functions
5. **TopicState** maintains a normalized store of entities from the WebSocket
6. Domain Mappers transform the raw entities into appropriate domain models
7. **TopicSession** publishes updates through its Combine publisher
8. **EveryMatrixEventsProvider** returns a subscription that includes:
   - The data stream with mapped domain models
   - A cancellation closure to clean up resources when no longer needed

## Data Flow Architecture

```
┌───────────────────┐          ┌───────────────────┐        ┌───────────────────┐
│     App Layer     │          │  EveryMatrix      │        │  Backend Server   │
│                   │          │  Provider         │        │                   │
│  ┌─────────────┐  │          │  ┌─────────────┐  │        │  ┌─────────────┐  │
│  │ UI Component│<─┼──Domain──┼──┤EveryMatrix  │  │        │  │ EveryMatrix │  │
│  └─────────────┘  │  Models  │  │EventsProvider│<─┼─WebSocket─┤  Backend   │  │
│                   │          │  └─────────────┘  │   Data  │  └─────────────┘  │
└───────────────────┘          │        ^          │        └───────────────────┘
                               │        │          │
                               │  ┌─────┴──────┐   │
                               │  │TopicManager│   │
                               │  └─────┬──────┘   │
                               │        │          │
                               │  ┌─────┴──────┐   │
                               │  │TopicSession│   │
                               │  └─────┬──────┘   │
                               │        │          │
                               │  ┌─────┴──────┐   │
                               │  │ TopicState │   │
                               │  └────────────┘   │
                               └───────────────────┘
```

## Message Processing Flow

```
┌───────────────────┐     ┌───────────────────┐     ┌───────────────────┐
│  WebSocket Message│     │     Actions       │     │   State Updates   │
│                   │     │                   │     │                   │
│  ┌─────────────┐  │     │  ┌─────────────┐  │     │  ┌─────────────┐  │
│  │Initial Dump │──┼─────┼─>│Insert Actions│──┼─────┼─>│State with   │  │
│  └─────────────┘  │     │  └─────────────┘  │     │  │Initial Data  │  │
│  ┌─────────────┐  │     │  ┌─────────────┐  │     │  ┌─────────────┐  │
│  │Update Message│──┼─────┼─>│Update Actions│──┼─────┼─>│Updated State│  │
│  └─────────────┘  │     │  └─────────────┘  │     │  └─────────────┘  │
│  ┌─────────────┐  │     │  ┌─────────────┐  │     │  ┌─────────────┐  │
│  │Delete Message│──┼─────┼─>│Delete Actions│──┼─────┼─>│State with   │  │
│  └─────────────┘  │     │  └─────────────┘  │     │  │Removed Entity│  │
└───────────────────┘     └───────────────────┘     └───────┬─────────┘
                                                            │
┌───────────────────┐     ┌───────────────────┐     ┌───────▼───────────┐
│  Domain Models    │     │   UI Component    │     │   Normalized      │
│                   │     │                   │     │   State Store     │
│  ┌─────────────┐  │     │  ┌─────────────┐  │     │  ┌─────────────┐  │
│  │SportType    │<─┼─────┼──┤Sports List  │  │     │  │Sports       │  │
│  └─────────────┘  │     │  └─────────────┘  │     │  └─────────────┘  │
│  ┌─────────────┐  │     │  ┌─────────────┐  │     │  ┌─────────────┐  │
│  │EventsGroup  │<─┼─────┼──┤Match List   │  │     │  │Matches      │  │
│  └─────────────┘  │     │  └─────────────┘  │     │  └─────────────┘  │
│  ┌─────────────┐  │     │  ┌─────────────┐  │     │  ┌─────────────┐  │
│  │Market       │<─┼─────┼──┤Betting UI   │  │     │  │Markets      │  │
│  └─────────────┘  │     │  └─────────────┘  │     │  └─────────────┘  │
└───────────────────┘     └───────────────────┘     └───────────────────┘
```

## Subscription Lifecycle

1. **Creation**
   - Client requests data via `EveryMatrixEventsProvider` (e.g., `subscribeSportTypes()`)
   - `TopicManager` creates a `TopicSession` for the requested topic
   - WebSocket connection is established or reused
   - Topic subscription message is sent to the server

2. **Data Processing**
   - Initial data dump is received and processed
   - Real-time updates are continuously processed
   - `TopicState` is updated with each change
   - Domain models are created from the normalized state

3. **Cancellation**
   - Client code invokes the cancellation closure
   - `TopicManager` removes the session and unsubscribes from the topic
   - WebSocket subscription is terminated (channel-specific)
   - Resources are cleaned up

## Key Benefits

1. **Strong Typing**: The entire data flow is type-safe, with no use of `Any` or untyped dictionaries.
2. **Normalized State**: Data is stored in a normalized form for efficient updates and lookups.
3. **Reactive Updates**: Combine publishers provide a reactive interface for continuous updates.
4. **Clean Architecture**: Clear separation of concerns between network layer, state management, and domain mapping.
5. **Memory Efficiency**: Resources are managed per topic, allowing fine-grained control over memory usage.
6. **Concurrency Safety**: Actor-based concurrency for thread-safe state updates.

## Implementation Status

The current implementation focuses on sports-related functionality:
- `subscribeSportTypes()`: Retrieves the list of available sports
- `subscribeLiveMatches()`: Subscribes to live matches for a specific sport

Additional functionality can be implemented by following the same pattern, creating new topic paths and mapping logic as needed.
