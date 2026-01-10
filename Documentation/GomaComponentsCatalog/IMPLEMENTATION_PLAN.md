# Implementation Plan

## Phase 0: Metadata Bootstrap (DONE)

Create the metadata infrastructure for LLM-driven enrichment.

### Tasks

- [x] Design `catalog-metadata.json` structure with status tracking
- [x] Create `bootstrap-catalog-metadata.js` script
- [x] Auto-detect categories from folder structure
- [x] Bootstrap 138 components with `status: "pending"`
- [x] Create `RALPH_CATALOG_METADATA.md` prompt for LLM enrichment

### Files Created

| File | Purpose |
|------|---------|
| `Frameworks/GomaUI/scripts/bootstrap-catalog-metadata.js` | Bootstraps empty metadata |
| `Frameworks/GomaUI/Documentation/catalog-metadata.json` | Rich metadata (LLM-enriched) |
| `Frameworks/GomaUI/Documentation/RALPH_CATALOG_METADATA.md` | Ralph loop prompt |

---

## Phase 1: LLM Metadata Enrichment (IN PROGRESS)

Use Ralph loop to analyze each component and fill metadata.

### Tasks

- [ ] Run Ralph loop with `RALPH_CATALOG_METADATA.md` prompt
- [ ] Verify all 138 components have `status: "complete"`
- [ ] Review quality of descriptions, tags, states
- [ ] Curate `featured` components list

### Run Command

```bash
/ralph-loop "$(cat Frameworks/GomaUI/Documentation/RALPH_CATALOG_METADATA.md)" --completion-promise "CATALOG_METADATA_COMPLETE" --max-iterations 30
```

---

## Phase 2: Catalog Generator Script

Create a Node.js script that merges all data sources into `catalog.json`.

### Tasks

- [ ] Create `Frameworks/GomaUI/scripts/generate-catalog.js`
- [ ] Merge `COMPONENT_MAP.json` (relationships)
- [ ] Merge `catalog-metadata.json` (descriptions, tags, states)
- [ ] Extract README.md content (first section)
- [ ] Map snapshot file paths for each component
- [ ] Output final `catalog.json`

### Input/Output

**Input:**
- `Frameworks/GomaUI/Documentation/COMPONENT_MAP.json`
- `Frameworks/GomaUI/Documentation/catalog-metadata.json`
- `Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/**/README.md`
- `Frameworks/GomaUI/GomaUI/Tests/GomaUITests/SnapshotTests/**/__Snapshots__/*.png`

**Output:**
- `Frameworks/GomaUI/Documentation/catalog.json`

---

## Phase 3: Web Catalog App

Create the Node.js Express app for the Hetzner server.

### Tasks

- [ ] Create `/Users/rroques/Desktop/GOMA/Tools/gomaui-catalog/` directory
- [ ] Initialize Node.js project (`package.json`)
- [ ] Create `server.js` with Express API
  - [ ] `GET /api/components` - List all components
  - [ ] `GET /api/components/:name` - Get single component
  - [ ] `GET /api/search` - Search with filters
  - [ ] `GET /api/health` - Health check
- [ ] Create `public/index.html` - SPA frontend
- [ ] Create `public/style.css` - Catalog styles
- [ ] Create `public/app.js` - Frontend logic with Fuse.js search
- [ ] Create `ecosystem.config.js` for PM2

### Frontend Features

- [ ] Component grid/list view
- [ ] Search bar with live filtering
- [ ] Category filter sidebar
- [ ] Tag filter chips
- [ ] Light/Dark mode snapshot toggle
- [ ] Component detail modal with README
- [ ] Parent/Children relationship links

---

## Phase 4: Server Deployment

Deploy the catalog app to Hetzner server.

### Tasks

- [ ] Create server directory: `ssh root@136.243.76.42 "mkdir -p /var/www/gomaui-catalog/{data,public/snapshots}"`
- [ ] Deploy app using existing `deploy-tool.sh` pattern
- [ ] Update ToolIndex `server.js` with gomaui-catalog metadata
- [ ] Update nginx config with `/gomaui-catalog/` location block
- [ ] Reload nginx: `sudo nginx -t && sudo systemctl reload nginx`
- [ ] Verify deployment: `https://tools.gomademo.com/gomaui-catalog/`

### Server Configuration

**Port:** 3013

**nginx location block:**
```nginx
location /gomaui-catalog/ {
    proxy_pass http://127.0.0.1:3013/;
    proxy_http_version 1.1;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
}
```

**ToolIndex metadata:**
```javascript
'gomaui-catalog': {
  port: 3013,
  description: 'GomaUI component catalog with visual snapshots'
}
```

---

## Phase 5: CI/CD Pipeline

Set up automated updates via GitHub Actions.

### Tasks

- [ ] Generate SSH key pair for GitHub Actions
- [ ] Add public key to Hetzner `authorized_keys`
- [ ] Add private key to GitHub Secrets as `HETZNER_SSH_KEY`
- [ ] Create `.github/workflows/update-gomaui-catalog.yml`
- [ ] Test workflow with manual trigger
- [ ] Verify automatic trigger on GomaUI changes

---

## Phase 6: Initial Data Sync

Perform first-time sync of all snapshots.

### Tasks

- [ ] Run `generate-catalog.js` locally
- [ ] Review generated `catalog.json` for accuracy
- [ ] Manually sync snapshots to server (may take time, ~100MB+)
- [ ] Verify all components display correctly in catalog

---

## Phase 7: Enhancements (Future)

Optional improvements after initial launch.

### Ideas

- [ ] Component dependency graph visualization (D3.js)
- [ ] "Similar Components" suggestions (prevent duplicates)
- [ ] Version history / changelog per component
- [ ] Usage statistics (which components are most viewed)
- [ ] Integration with GomaUICatalog app (deep links)
- [ ] Figma links for components with design specs
- [ ] Code snippet examples from README.md

---

## File Checklist

### iOS Repo (Source)

```
sportsbook-ios/
├── .github/workflows/
│   └── update-gomaui-catalog.yml         # [Phase 5]
└── Frameworks/GomaUI/
    ├── Documentation/
    │   ├── COMPONENT_MAP.json            # [Existing] Relationships
    │   ├── catalog-metadata.json         # [Phase 0] ✓ Rich metadata
    │   ├── catalog.json                  # [Phase 2] Generated output
    │   └── RALPH_CATALOG_METADATA.md     # [Phase 0] ✓ LLM prompt
    └── scripts/
        ├── bootstrap-catalog-metadata.js # [Phase 0] ✓ Bootstraps metadata
        └── generate-catalog.js           # [Phase 2] Merges all sources
```

### Tools Repo (Local)

```
/Users/rroques/Desktop/GOMA/Tools/gomaui-catalog/
├── package.json                      # [Phase 2]
├── server.js                         # [Phase 2]
├── ecosystem.config.js               # [Phase 2]
├── public/
│   ├── index.html                    # [Phase 2]
│   ├── style.css                     # [Phase 2]
│   └── app.js                        # [Phase 2]
└── data/
    └── catalog.json                  # [Synced from iOS]
```

### Hetzner Server

```
/var/www/gomaui-catalog/
├── package.json
├── server.js
├── ecosystem.config.js
├── node_modules/
├── data/
│   └── catalog.json
└── public/
    ├── index.html
    ├── style.css
    ├── app.js
    └── snapshots/
        ├── ActionButtonBlockView/
        ├── ButtonView/
        └── ... (140+ component folders)
```

---

## Success Criteria

1. **Catalog accessible** at `https://tools.gomademo.com/gomaui-catalog/`
2. **All 140+ components** listed with metadata
3. **Snapshots display** correctly (light/dark toggle)
4. **Search works** - finds components by name, description, tags
5. **Filters work** - category and tag filtering
6. **Auto-updates** - CI pushes changes within minutes of merge
7. **README visible** - component documentation rendered

---

## Notes

- Estimated total effort: 3-5 days
- Can be implemented incrementally (Phase 1-3 first, CI later)
- No blocking dependencies on iOS development work
- HTTP Basic Auth inherited from ToolIndex nginx config
