# UI Elements Components

This folder contains generic, reusable UI primitives that can be used across different features.

## Components

### Buttons & Actions
| Component | Description |
|-----------|-------------|
| `ButtonView` | Customizable button component with multiple styles |
| `ButtonIconView` | Icon button component |
| `QuickAddButtonView` | Quick add/action button |

### Labels & Text
| Component | Description |
|-----------|-------------|
| `CapsuleView` | Pill-shaped container for badges, status indicators, counts |
| `HighlightedTextView` | Text with highlighted portions |
| `HeaderTextView` | Header text display |

### Rows & Lists
| Component | Description |
|-----------|-------------|
| `InfoRowView` | Customizable info row component |
| `ActionRowView` | Row with action capability |
| `SimpleOptionRowView` | Simple option row for lists |
| `StepInstructionView` | Step-by-step instruction display |

### Expandable Content
| Component | Description |
|-----------|-------------|
| `ExpandableSectionView` | Expandable section with header and toggle |
| `CustomExpandableSectionView` | Expandable section with leading icons and custom expand/collapse icons |

### Footer & Navigation
| Component | Description |
|-----------|-------------|
| `ExtendedListFooterView` | Comprehensive footer with logos, links, payment providers, etc. |
| `SquareSeeMoreView` | Square "See More" button |

### Specialized
| Component | Description |
|-----------|-------------|
| `StatisticsWidgetView` | Web-based statistics widget with paginated scroll |

## Usage

These components are used across the entire application as building blocks for more complex UI compositions.

## Architecture

All components follow GomaUI's standard MVVM pattern with protocol-driven ViewModels, mock implementations, and Combine-based reactive bindings.
