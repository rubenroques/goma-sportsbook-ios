# GomaUI Components Catalog

A web-based catalog for browsing, searching, and discovering GomaUI components with visual snapshots.

## Project Status

**Status**: Planning
**Target URL**: `https://tools.gomademo.com/gomaui-catalog/`
**Server**: Hetzner (`root@136.243.76.42`)

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

### Data Sources
- `COMPONENT_MAP.json` - Component relationships and metadata
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
| Snapshots | `Frameworks/GomaUI/GomaUI/Tests/GomaUITests/SnapshotTests/` |
| ToolIndex | `/Users/rroques/Desktop/GOMA/Tools/ToolIndex/` |
| Server | `ssh root@136.243.76.42` |

## Related Documentation

- [Snapshot Testing Guide](../../Frameworks/GomaUI/GomaUI/Documentation/SNAPSHOT_TESTING_GUIDE.md)
- [UI Component Guide](../UI_COMPONENT_GUIDE.md)
