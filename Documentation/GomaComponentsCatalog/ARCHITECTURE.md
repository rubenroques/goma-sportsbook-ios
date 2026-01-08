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

### Source 1: COMPONENT_MAP.json (iOS Repo)

Component relationships maintained by Ralph automation:

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

### Source 2: catalog-metadata.json (iOS Repo)

Rich metadata for catalog UX, enriched by LLM:

```json
{
  "version": "1.0.0",
  "generated": "2026-01-08T17:56:49.695Z",
  "featured": [],
  "categories": {
    "Betting": {
      "description": "Components for odds, markets, betslip, and bet placement",
      "subcategories": ["Odds", "Markets", "BetSlip", "Outcomes", "Cashout", "Tickets"]
    }
  },
  "components": {
    "OutcomeItemView": {
      "status": "complete",
      "displayName": "OutcomeItemView",
      "category": "Betting",
      "subcategory": "Outcomes",
      "summary": "Single betting outcome with odds and selection state",
      "description": "Displays an individual betting market outcome. Supports selection states (unselected, selected, suspended), odds change animations with up/down indicators, and configurable layouts.",
      "complexity": "simple",
      "maturity": "stable",
      "tags": ["betting", "odds", "outcome", "selection", "interactive", "animation"],
      "states": ["unselected", "selected", "suspended", "oddsUp", "oddsDown"],
      "similarTo": ["QuickAddButtonView"],
      "oftenUsedWith": ["MarketOutcomesLineView", "CompactOutcomesLineView"]
    }
  }
}
```

**Status tracking:**
- `pending` - Not yet analyzed by LLM
- `partial` - Some fields filled
- `complete` - Fully analyzed and verified

### Generated: catalog.json (Server)

Final merged catalog combining COMPONENT_MAP + catalog-metadata + snapshots:

```json
{
  "version": "1.0.0",
  "generated": "2026-01-08T10:30:00Z",
  "featured": ["OutcomeItemView", "ButtonView", "MatchHeaderCompactView"],
  "categories": { ... },
  "components": {
    "OutcomeItemView": {
      "displayName": "OutcomeItemView",
      "category": "Betting",
      "subcategory": "Outcomes",
      "summary": "Single betting outcome with odds and selection state",
      "description": "Displays an individual betting market outcome...",
      "complexity": "simple",
      "maturity": "stable",
      "tags": ["betting", "odds", "selection", "animation", "interactive"],
      "states": ["unselected", "selected", "suspended", "oddsUp", "oddsDown"],
      "similarTo": ["QuickAddButtonView"],
      "oftenUsedWith": ["MarketOutcomesLineView", "CompactOutcomesLineView"],
      "parents": ["CompactOutcomesLineView", "MarketOutcomesLineView"],
      "children": [],
      "has_readme": true,
      "readme_content": "# OutcomeItemView\n\n...",
      "snapshots": [
        {
          "category": "BasicStates",
          "light": "OutcomeItemView/.../testOutcomeItemView_BasicStates_Light.1.png",
          "dark": "OutcomeItemView/.../testOutcomeItemView_BasicStates_Dark.1.png"
        }
      ]
    }
  }
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
