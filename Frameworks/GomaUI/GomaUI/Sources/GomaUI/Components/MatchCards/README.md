# Match Cards Components

This folder contains UI components for displaying sports match information, including composite match cards and their sub-components.

## Composite Components (Main Cards)

| Component | Description |
|-----------|-------------|
| `TallOddsMatchCardView` | Full-featured vertical match card with header, participants, and betting outcomes |
| `InlineMatchCardView` | Compact horizontal match card for list displays with real-time updates |

## Sub-Components

### Headers & Navigation
| Component | Description |
|-----------|-------------|
| `MatchHeaderView` | Competition header with country flag, sport icon, and favorite toggle |
| `MatchHeaderCompactView` | Compact header with teams, competition breadcrumb, and stats button |
| `MatchDateNavigationBar` | Navigation bar with match timing (pre-match date or live status) |
| `CompactMatchHeaderView` | Pre-live date/time or LIVE badge with status and market count |

### Participants & Scores
| Component | Description |
|-----------|-------------|
| `MatchParticipantsInfoView` | Flexible participants display with scores and serving indicators |
| `ScoreView` | Flexible sports match score display with multiple cells and styles |
| `InlineScoreView` | Multi-column score display for live matches (football, tennis, basketball) |

### Outcomes
| Component | Description |
|-----------|-------------|
| `CompactOutcomesLineView` | 2-way or 3-way betting outcomes in compact horizontal layout |

### Banners
| Component | Description |
|-----------|-------------|
| `MatchBannerView` | Match banner for live/prelive matches in promotional sliders |

## Component Hierarchy

```
TallOddsMatchCardView (composite)
├── MatchHeaderView
├── MatchParticipantsInfoView
│   └── ScoreView
└── MarketOutcomesLineView (from Betting/)

InlineMatchCardView (composite)
├── CompactMatchHeaderView
├── MatchParticipantsInfoView
│   └── InlineScoreView
└── CompactOutcomesLineView
```

## Usage

These components are used in:
- Home screen match listings
- Sports category screens
- Live betting sections
- Favorites/My Bets screens

## Architecture

All components follow GomaUI's standard MVVM pattern with protocol-driven ViewModels, mock implementations, and Combine-based reactive bindings.
