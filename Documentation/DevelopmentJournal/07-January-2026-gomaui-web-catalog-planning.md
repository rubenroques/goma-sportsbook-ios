## Date
07 January 2026

### Project / Branch
sportsbook-ios / rw/snapshot_tests

### Goals for this session
- Brainstorm web-based catalog for GomaUI components
- Design CI/CD pipeline for automatic catalog updates
- Document architecture and implementation plan

### Achievements
- [x] Analyzed existing infrastructure (COMPONENT_MAP.json, snapshots, READMEs)
- [x] Explored ToolIndex server structure on Hetzner (tools.gomademo.com)
- [x] Designed complete architecture for GomaUI web catalog
- [x] Created comprehensive documentation in `Documentation/GomaComponentsCatalog/`
- [x] Documented rsync incremental sync to avoid uploading all images every time

### Issues / Bugs Hit
- None - this was a planning/documentation session

### Key Decisions
- **Hosting**: Use existing Hetzner server at `136.243.76.42` alongside other tools
- **CI/CD Strategy**: GitHub Actions SSH push (Option 1) - fully automated on merge to main
- **Incremental Sync**: rsync with `--checksum` flag ensures only changed PNGs are transferred
- **Tech Stack**: Vanilla JS + Express (no React/Vue overhead for simple tool)
- **Port**: 3013 for gomaui-catalog service
- **URL**: `https://tools.gomademo.com/gomaui-catalog/`

### Experiments & Notes
- Reviewed existing COMPONENT_MAP.json - already has 140+ components with parent/child relationships
- Snapshot naming convention: `test{Component}_{Category}_{Light|Dark}.1.png`
- Estimated ~300+ PNG files, ~100-200 MB total
- rsync with checksum mode: first sync ~150MB, subsequent syncs only changed files (~1-5MB typical)

### Useful Files / Links
- [GomaComponentsCatalog README](../GomaComponentsCatalog/README.md)
- [Architecture](../GomaComponentsCatalog/ARCHITECTURE.md)
- [CI/CD Pipeline](../GomaComponentsCatalog/CICD.md)
- [Data Flow](../GomaComponentsCatalog/DATA_FLOW.md)
- [Implementation Plan](../GomaComponentsCatalog/IMPLEMENTATION_PLAN.md)
- [Component Map JSON](../../Frameworks/GomaUI/Documentation/COMPONENT_MAP.json)
- [ToolIndex Server](/Users/rroques/Desktop/GOMA/Tools/ToolIndex/)

### Next Steps
1. Phase 1: Create `scripts/generate-catalog.js` to enrich COMPONENT_MAP.json
2. Phase 2: Build Node.js catalog app in `/Users/rroques/Desktop/GOMA/Tools/gomaui-catalog/`
3. Phase 3: Deploy to Hetzner using existing deploy-tool.sh pattern
4. Phase 4: Set up GitHub Actions workflow with SSH key
5. Phase 5: Initial data sync (~150MB of snapshots)

### Documentation Created
| File | Lines | Purpose |
|------|-------|---------|
| README.md | 58 | Project overview, goals, quick links |
| ARCHITECTURE.md | 193 | System diagram, data model, API endpoints |
| CICD.md | 282 | GitHub Actions workflow, SSH setup |
| DATA_FLOW.md | 210 | Visual data flow, incremental sync details |
| IMPLEMENTATION_PLAN.md | 211 | 6 phases with checkboxes |
