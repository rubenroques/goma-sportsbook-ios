# Implementation Plan

## Phase 1: Catalog Generator Script

Create a Node.js script that transforms `COMPONENT_MAP.json` into an enriched `catalog.json`.

### Tasks

- [ ] Create `scripts/generate-catalog.js` in iOS repo
- [ ] Parse `COMPONENT_MAP.json`
- [ ] Extract descriptions from README.md files (first paragraph)
- [ ] Infer categories from component folder paths
- [ ] Generate tags based on content analysis
- [ ] Map snapshot file paths for each component
- [ ] Output enhanced `catalog.json`

### Input/Output

**Input:**
- `Frameworks/GomaUI/Documentation/COMPONENT_MAP.json`
- `Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/**/README.md`
- `Frameworks/GomaUI/GomaUI/Tests/GomaUITests/SnapshotTests/**/__Snapshots__/*.png`

**Output:**
- `Frameworks/GomaUI/Documentation/catalog.json`

---

## Phase 2: Web Catalog App

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

## Phase 3: Server Deployment

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

## Phase 4: CI/CD Pipeline

Set up automated updates via GitHub Actions.

### Tasks

- [ ] Generate SSH key pair for GitHub Actions
- [ ] Add public key to Hetzner `authorized_keys`
- [ ] Add private key to GitHub Secrets as `HETZNER_SSH_KEY`
- [ ] Create `.github/workflows/update-gomaui-catalog.yml`
- [ ] Test workflow with manual trigger
- [ ] Verify automatic trigger on GomaUI changes

---

## Phase 5: Initial Data Sync

Perform first-time sync of all snapshots.

### Tasks

- [ ] Run `generate-catalog.js` locally
- [ ] Review generated `catalog.json` for accuracy
- [ ] Manually sync snapshots to server (may take time, ~100MB+)
- [ ] Verify all components display correctly in catalog

---

## Phase 6: Enhancements (Future)

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
├── scripts/
│   ├── generate-catalog.js          # [Phase 1]
│   └── sync-catalog-manual.sh       # [Phase 1]
├── .github/workflows/
│   └── update-gomaui-catalog.yml    # [Phase 4]
└── Frameworks/GomaUI/Documentation/
    └── catalog.json                  # [Generated]
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
