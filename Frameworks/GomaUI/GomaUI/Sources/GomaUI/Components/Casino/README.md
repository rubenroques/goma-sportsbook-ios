# Casino Components

This folder contains UI components for the casino game display, categories, and game selection.

## Components

### Section Components
| Component | Description |
|-----------|-------------|
| `CasinoCategorySectionView` | Complete casino section with category bar and horizontal game collection |
| `CasinoCategoryBarView` | Category header with title and "See All" action button |

### Game Display Components
| Component | Description |
|-----------|-------------|
| `CasinoGameCardView` | Individual game card with image, rating, and info |
| `CasinoGameImageView` | Single game image display |
| `CasinoGameImagePairView` | Pair of game images side by side |
| `CasinoGameImageGridSectionView` | Grid layout section for game images |

### Game Interaction Components
| Component | Description |
|-----------|-------------|
| `CasinoGamePlayModeSelectorView` | Pre-game component with play mode buttons (demo/real) |
| `CasinoGameSearchedView` | Search result game display |
| `RecentlyPlayedGamesView` | Horizontal collection of recently played games |

## Component Hierarchy

```
CasinoCategorySectionView (composite)
├── CasinoCategoryBarView
└── CasinoGameCardView (collection)

CasinoGameImageGridSectionView (composite)
├── CasinoGameImageView
└── CasinoGameImagePairView

RecentlyPlayedGamesView (composite)
└── CasinoGameCardView (collection)
```

## Usage

These components are used in:
- Casino home screen
- Game category screens
- Search results
- Recently played sections
- Game detail overlays

## Architecture

All components follow GomaUI's standard MVVM pattern with protocol-driven ViewModels, mock implementations, and Combine-based reactive bindings.
