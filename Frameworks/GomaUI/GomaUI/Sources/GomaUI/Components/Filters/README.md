# Filters Components

This folder contains UI components for filtering, sorting, and selection interfaces.

## Components

### Filter Bars
| Component | Description |
|-----------|-------------|
| `GeneralFilterBarView` | General purpose filter bar container |
| `MainFilterPillView` | Main filter pill with action icon |
| `SimpleSquaredFilterBar` | Simple squared filter bar layout |

### Pill Selection
| Component | Description |
|-----------|-------------|
| `PillItemView` | Customizable pill-shaped selector with icon and selection state |
| `PillSelectorBarView` | Horizontal scrollable collection of pills with fade effects |

### Sport Filters
| Component | Description |
|-----------|-------------|
| `SportGamesFilterView` | Filter view for selecting sports |
| `SportTypeSelectorView` | Full-screen sport selection with 2-column layout |
| `SportTypeSelectorItemView` | Individual sport item with icon and text |
| `SportSelectorCell` | Sport selector cell for collections |

### League/Country Filters
| Component | Description |
|-----------|-------------|
| `CountryLeaguesFilterView` | Filter for selecting country leagues with expandable sections |
| `LeaguesFilterView` | Leagues filter component |

### Sorting & Time
| Component | Description |
|-----------|-------------|
| `SortFilterView` | Sorting options filter view |
| `TimeSliderView` | Interactive time-based filter with slider |

### Utility
| Component | Description |
|-----------|-------------|
| `FilterOptionCell` | Generic filter option cell |

## Component Hierarchy

```
PillSelectorBarView (composite)
└── PillItemView (multiple)

SportTypeSelectorView (composite)
└── SportTypeSelectorItemView (collection)

CountryLeaguesFilterView (composite)
└── LeaguesFilterView (expandable sections)
```

## Usage

These components are used in:
- Sports filter screens
- Market filter overlays
- Time range selection
- Category filtering

## Architecture

All components follow GomaUI's standard MVVM pattern with protocol-driven ViewModels, mock implementations, and Combine-based reactive bindings.
