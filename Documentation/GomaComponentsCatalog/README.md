# GomaUI Components Catalog

A web-based catalog for browsing, searching, and discovering GomaUI components with visual snapshots.

## Project Status

**Status**: In Progress (Phase 1 - Metadata)
**Target URL**: `https://tools.gomademo.com/gomaui-catalog/`
**Server**: Hetzner (`root@136.243.76.42`)

### Progress

| Phase | Status | Description |
|-------|--------|-------------|
| Metadata Bootstrap | Done | 138 components bootstrapped with categories |
| LLM Enrichment | Pending | Fill descriptions, tags, states via Ralph |
| Catalog Generator | Pending | Merge metadata + snapshots into catalog.json |
| Web App | Pending | Frontend and API |
| CI/CD | Pending | Automated updates |

## Goals

1. **Discoverability** - Search and browse 140+ GomaUI components
2. **Visual Reference** - View snapshot tests in light/dark modes
3. **Prevent Duplication** - Find existing components before creating new ones
4. **Documentation Hub** - Access README.md documentation per component
5. **Dependency Visualization** - Understand parent/child component relationships

## Features

### Core Features
- Full-text search across component names, descriptions, and tags
- Filter by category (Betting, Casino, Forms, Navigation, etc.)
- Filter by tags (animation, interactive, readonly, etc.)
- Light/Dark mode snapshot toggle
- Component relationship graph (parents/children)
- README.md documentation viewer
- Featured components section (curated highlights)
- Similar components suggestions

### Data Sources
- `COMPONENT_MAP.json` - Component relationships (parent/child, has_readme, has_snapshot_tests)
- `catalog-metadata.json` - Rich metadata (descriptions, tags, states, complexity)
- `__Snapshots__/*.png` - Visual snapshots from unit tests
- `Documentation/README.md` - Per-component documentation

## Architecture

See [ARCHITECTURE.md](./ARCHITECTURE.md) for technical details.

## CI/CD

See [CICD.md](./CICD.md) for the automated update pipeline.

## Implementation Plan

See [IMPLEMENTATION_PLAN.md](./IMPLEMENTATION_PLAN.md) for step-by-step tasks.

## Quick Links

| Resource | Location |
|----------|----------|
| Component Map | `Frameworks/GomaUI/Documentation/COMPONENT_MAP.json` |
| Catalog Metadata | `Frameworks/GomaUI/Documentation/catalog-metadata.json` |
| Bootstrap Script | `Frameworks/GomaUI/scripts/bootstrap-catalog-metadata.js` |
| Ralph Prompt | `Frameworks/GomaUI/Documentation/RALPH_CATALOG_METADATA.md` |
| Snapshots | `Frameworks/GomaUI/GomaUI/Tests/GomaUITests/SnapshotTests/` |
| ToolIndex | `/Users/rroques/Desktop/GOMA/Tools/ToolIndex/` |
| Server | `ssh root@136.243.76.42` |

## Metadata Enrichment

The catalog uses LLM-driven metadata enrichment via Ralph loop:

```bash
# Run the enrichment loop (processes 5 components per iteration)
/ralph-loop "$(cat Frameworks/GomaUI/Documentation/RALPH_CATALOG_METADATA.md)" --completion-promise "CATALOG_METADATA_COMPLETE" --max-iterations 30
```

Progress is tracked in `catalog-metadata.json` via the `status` field:
- `pending` - Not yet analyzed (138 initially)
- `partial` - Some fields filled
- `complete` - Fully analyzed

## Related Documentation

- [Snapshot Testing Guide](../../Frameworks/GomaUI/GomaUI/Documentation/SNAPSHOT_TESTING_GUIDE.md)
- [UI Component Guide](../UI_COMPONENT_GUIDE.md)
- [Ralph Catalog Metadata Prompt](../../Frameworks/GomaUI/Documentation/RALPH_CATALOG_METADATA.md)
