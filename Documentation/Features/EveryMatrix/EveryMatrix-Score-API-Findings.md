# EveryMatrix Score API Documentation

## Overview

This document details the findings from analyzing EveryMatrix WebSocket API score data (`EVENT_INFO` with `typeId: "1"`). The API sends comprehensive score information for various sports, with different patterns for football, tennis, and other sports.

## Key Discoveries

### 1. Participant ID Mapping
**CRITICAL**: Score values are NOT always in home/away order. The API uses `paramParticipantId1` and `paramParticipantId2` to indicate which team each score belongs to:

- `paramFloat1` → belongs to participant identified by `paramParticipantId1`
- `paramFloat2` → belongs to participant identified by `paramParticipantId2`

You MUST check these participant IDs against `MatchDTO.homeParticipantId` and `MatchDTO.awayParticipantId` to correctly assign scores.

### 2. EventPartId is More Reliable Than String Matching
Instead of relying on `eventPartName` string comparisons, use `eventPartId` for reliable score type identification.

### 3. StatusId Indicates Active vs Completed
- `StatusId: "1"` = Currently active/in-progress
- `StatusId: "4"` = Completed/finished

This is crucial for tennis to filter out historical game scores.

---

## Football/Soccer Scores

### EventPartId Mappings
| EventPartId | EventPartName | Description | Usage |
|------------|---------------|-------------|-------|
| `"2"` | "Whole Match" | Main match score | **Use as main score** |
| `"3"` | "Ordinary Time" | Regular time score | Additional detail only |
| `"5"` | "1st Half" | First half score | Additional detail only |
| `"6"` | "2nd Half" | Second half score | Additional detail only |

### Football Score Example
```
Event: 282286455455354880
EventPartName: Whole Match
EventPartId: 2
ParamScoringUnitName1: Goal
ParamFloat1: 0.0 → AWAY (Soccer Saga)
ParamFloat2: 0.0 → HOME (Kopana FC)
```

### Implementation Strategy
- Only use `EventPartId: "2"` for main match score
- Ignore other EventPartIds or store as detailed scores

---

## Tennis Scores

Tennis sends ALL game scores throughout the match. We need to filter intelligently.

### EventPartId Mappings

#### Match Level
| EventPartId | EventPartName | ParamScoringUnit | Description |
|------------|---------------|------------------|-------------|
| `"20"` | "Whole Match" | "Set" | Sets won by each player |

#### Set Level
| EventPartId | EventPartName | ParamScoringUnit | Description |
|------------|---------------|------------------|-------------|
| `"21"` | "1st Set" | "Game" | Games won in 1st set |
| `"22"` | "2nd Set" | "Game" | Games won in 2nd set |
| `"23"` | "3rd Set" | "Game" | Games won in 3rd set |
| `"24"` | "4th Set" | "Game" | Games won in 4th set |
| `"25"` | "5th Set" | "Game" | Games won in 5th set |

#### Game Level (400-500 range)
| EventPartId Range | EventPartName Pattern | ParamScoringUnit | Description |
|------------------|----------------------|------------------|-------------|
| `"401"` | "1st Game (1st Set)" | "Point" | Points in game (0,15,30,40,50) |
| `"402"` | "2nd Game (1st Set)" | "Point" | 50 = Advantage |
| `"421"` | "1st Game (2nd Set)" | "Point" | StatusId:"1" = current game |
| `"427"` | "7th Game (2nd Set)" | "Point" | StatusId:"4" = finished game |

#### Tie-Break
| EventPartId | EventPartName | ParamScoringUnit | Description |
|------------|---------------|------------------|-------------|
| `"574"` | "Tie-Break (1st Set)" | "Tie-Break Point" | Tie-break points |

### Tennis Score Examples

#### Whole Match (Sets Won)
```
EventPartName: Whole Match
EventPartId: 20
ParamScoringUnitName1: Set
ParamFloat1: 0.0 → HOME (Benjamin Bonzi)
ParamFloat2: 1.0 → AWAY (Fabian Marozsan)
```

#### Individual Set (Games Won)
```
EventPartName: 1st Set
EventPartId: 21
ParamScoringUnitName1: Game
ParamFloat1: 6.0 → HOME (Benjamin Bonzi)
ParamFloat2: 7.0 → AWAY (Fabian Marozsan)
```

#### Current Game (Active)
```
EventPartName: 7th Game (2nd Set)
EventPartId: 427
StatusId: 1  ← ACTIVE
ParamScoringUnitName1: Point
ParamFloat1: 50.0 → HOME (Benjamin Bonzi)  // Advantage
ParamFloat2: 40.0 → AWAY (Fabian Marozsan)
```

#### Completed Game (Should Filter Out)
```
EventPartName: 1st Game (2nd Set)
EventPartId: 421
StatusId: 4  ← COMPLETED
ParamScoringUnitName1: Point
ParamFloat1: 40.0 → HOME
ParamFloat2: 30.0 → AWAY
```

### Tennis Implementation Strategy

1. **Show only**:
   - Whole match score (EventPartId: "20")
   - All set scores (EventPartId: "21"-"25")
   - ONLY current game (EventPartId: 400+ with StatusId: "1")

2. **Filter out**:
   - Completed games (StatusId: "4")
   - Tie-breaks (EventPartId: "574") - not supported

---

## Cricket Scores

### EventPartId Mappings (Partial)
| EventPartId | EventPartName | Description |
|------------|---------------|-------------|
| `"787"` | "2nd Innings" | Second innings score |

*Note: Cricket patterns need more investigation*

---

## Score Enum Mapping

### Current Score Enum Cases
```swift
public enum Score: Codable, Hashable {
    case matchFull(home: Int?, away: Int?)  // Full match score
    case set(index: Int, home: Int?, away: Int?)  // Set/period scores
    case gamePart(home: Int?, away: Int?)  // Game/point scores
}
```

### Recommended Mapping Logic

```swift
// Football
if eventPartId == "2" {
    → .matchFull(home: homeValue, away: awayValue)
}

// Tennis - Match
else if eventPartId == "20" {
    → .matchFull(home: homeValue, away: awayValue)
}

// Tennis - Sets
else if ["21", "22", "23", "24", "25"].contains(eventPartId) {
    let setIndex = Int(eventPartId)! - 20  // 21→1, 22→2, etc.
    → .set(index: setIndex, home: homeValue, away: awayValue)
}

// Tennis - Games (only if active)
else if let partId = Int(eventPartId), partId >= 400 && partId < 500 {
    if statusId == "1" {  // Active game only
        → .gamePart(home: homeValue, away: awayValue)
    } else {
        → SKIP  // Don't add completed games
    }
}

// Tennis - Tie-break (not supported)
else if eventPartId == "574" {
    → SKIP
}
```

---

## Common Pitfalls

1. **Never assume paramFloat1 is home** - Always check paramParticipantId1/2
2. **Don't rely on string matching alone** - EventPartId is more reliable
3. **Filter tennis games by StatusId** - Only show active games
4. **Remember sport differences** - Football uses EventPartId:"2", Tennis uses "20" for whole match

---

## Testing Checklist

- [ ] Football: Only main score shows (EventPartId: "2")
- [ ] Tennis: Match score shows (EventPartId: "20")
- [ ] Tennis: All set scores show (EventPartId: "21"-"25")
- [ ] Tennis: Only current game shows (StatusId: "1")
- [ ] Tennis: Completed games are filtered out (StatusId: "4")
- [ ] Tennis: Tie-breaks are ignored (EventPartId: "574")
- [ ] Scores map correctly to home/away based on participant IDs

---

## Future Considerations

1. **Basketball/Volleyball**: Need to investigate quarter/set patterns
2. **Cricket**: Complex innings structure needs more analysis
3. **Baseball**: Innings pattern similar to cricket?
4. **Other Sports**: Each sport may have unique EventPartId patterns

---

*Last Updated: September 2025*
*Based on: EveryMatrix WebSocket API analysis*