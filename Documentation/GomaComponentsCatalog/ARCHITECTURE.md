# Architecture

## System Overview

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           iOS Repository (Source)                            │
│                                                                              │
│  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────────────┐  │
│  │ COMPONENT_MAP    │  │ Snapshot Tests   │  │ Component README.md      │  │
│  │ .json            │  │ __Snapshots__/   │  │ Documentation/           │  │
│  └────────┬─────────┘  └────────┬─────────┘  └────────────┬─────────────┘  │
│           │                     │                         │                 │
│           └─────────────────────┼─────────────────────────┘                 │
│                                 │                                           │
│                    ┌────────────▼────────────┐                              │
│                    │   GitHub Actions CI     │                              │
│                    │   (on push to main)     │                              │
│                    └────────────┬────────────┘                              │
└─────────────────────────────────┼───────────────────────────────────────────┘
                                  │
                                  │ SSH + rsync
                                  │
┌─────────────────────────────────▼───────────────────────────────────────────┐
│                        Hetzner Server (136.243.76.42)                        │
│                                                                              │
│  ┌────────────────────────────────────────────────────────────────────────┐ │
│  │                              nginx                                      │ │
│  │                     tools.gomademo.com                                  │ │
│  │                   (HTTP Basic Auth enabled)                             │ │
│  └───────────────────────────────┬────────────────────────────────────────┘ │
│                                  │                                          │
│         ┌────────────────────────┼────────────────────────┐                 │
│         │                        │                        │                 │
│         ▼                        ▼                        ▼                 │
│  ┌──────────────┐     ┌──────────────────┐     ┌──────────────────┐        │
│  │ /            │     │ /gomaui-catalog/ │     │ /color-tool/     │        │
│  │ tools-index  │     │ Port 3013        │     │ Port 3012        │        │
│  │ Port 3000    │     │                  │     │                  │        │
│  └──────────────┘     └──────────────────┘     └──────────────────┘        │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘
```

## Catalog App Structure

```
/var/www/gomaui-catalog/
├── package.json
├── ecosystem.config.js          # PM2 configuration
├── server.js                    # Express API server
│
├── data/
│   └── catalog.json             # Enhanced component metadata
│
├── public/
│   ├── index.html               # SPA entry point
│   ├── style.css                # Catalog styles
│   ├── app.js                   # Frontend application
│   │
│   └── snapshots/               # Synced from iOS repo
│       ├── ActionButtonBlockView/
│       │   └── ActionButtonBlockViewSnapshotTests/
│       │       ├── testActionButtonBlockView_BasicStates_Light.1.png
│       │       └── testActionButtonBlockView_BasicStates_Dark.1.png
│       ├── ButtonView/
│       │   └── ButtonViewSnapshotTests/
│       │       ├── testButtonView_BasicStyles_Light.1.png
│       │       ├── testButtonView_BasicStyles_Dark.1.png
│       │       └── ...
│       └── ... (140+ components)
│
└── scripts/
    └── generate-catalog.js      # Transforms COMPONENT_MAP.json → catalog.json
```

## Data Model

### Source: COMPONENT_MAP.json (iOS Repo)

Current structure maintained by Ralph automation:

```json
{
  "OutcomeItemView": {
    "children": [],
    "has_readme": true,
    "parents": ["CompactOutcomesLineView", "MarketOutcomesLineView"],
    "readme_done": true,
    "has_snapshot_tests": true
  }
}
```

### Generated: catalog.json (Server)

Enhanced structure for web catalog:

```json
{
  "version": "1.0.0",
  "generated": "2026-01-07T10:30:00Z",
  "components": {
    "OutcomeItemView": {
      "name": "OutcomeItemView",
      "category": "Betting",
      "description": "Individual betting market outcome with selection states and odds change animations",
      "tags": ["betting", "odds", "selection", "animation", "interactive"],
      "has_readme": true,
      "readme_content": "# OutcomeItemView\n\nOutcomeItemView is a reusable component...",
      "parents": ["CompactOutcomesLineView", "MarketOutcomesLineView"],
      "children": [],
      "snapshots": [
        {
          "category": "BasicStates",
          "light": "OutcomeItemView/OutcomeItemViewSnapshotTests/testOutcomeItemView_BasicStates_Light.1.png",
          "dark": "OutcomeItemView/OutcomeItemViewSnapshotTests/testOutcomeItemView_BasicStates_Dark.1.png"
        },
        {
          "category": "OddsChange",
          "light": "OutcomeItemView/OutcomeItemViewSnapshotTests/testOutcomeItemView_OddsChange_Light.1.png",
          "dark": "OutcomeItemView/OutcomeItemViewSnapshotTests/testOutcomeItemView_OddsChange_Dark.1.png"
        }
      ]
    }
  },
  "categories": ["Betting", "Casino", "Filters", "Forms", "MatchCards", "Navigation", "Promotions", "Status", "UIElements", "Wallet"],
  "tags": ["animation", "interactive", "readonly", "selection", "betting", "casino", "form", "navigation"]
}
```

## API Endpoints

### GET /api/components

Returns all components with full metadata.

```json
{
  "components": [...],
  "total": 141,
  "categories": [...],
  "tags": [...]
}
```

### GET /api/components/:name

Returns single component with full details including README content.

### GET /api/search?q=outcome&category=Betting&tags=animation

Search with filters.

```json
{
  "results": [...],
  "total": 5,
  "query": "outcome",
  "filters": {
    "category": "Betting",
    "tags": ["animation"]
  }
}
```

### GET /api/health

Health check for monitoring.

## Frontend Stack

**Vanilla JS + CSS** (no build step required)

- Fuse.js for client-side fuzzy search
- Native fetch for API calls
- CSS Grid for responsive layout
- CSS custom properties for theming

Rationale: Simple tool, no need for React/Vue overhead. Keeps deployment simple.

## Security

- HTTP Basic Auth via nginx (existing `.htpasswd`)
- No public exposure
- Internal team tool only

## Performance Considerations

- Snapshots served directly by nginx (static files)
- catalog.json loaded once, cached in memory
- Client-side search (no server roundtrip for filtering)
- Lazy loading for images (intersection observer)
