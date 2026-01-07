# CI/CD Pipeline

## Overview

The catalog is automatically updated when changes are pushed to the `main` branch that affect GomaUI components or snapshots.

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│   Developer     │     │  GitHub Actions │     │ Hetzner Server  │
│   pushes to     │────▶│  runs workflow  │────▶│  receives       │
│   main branch   │     │                 │     │  updated files  │
└─────────────────┘     └─────────────────┘     └─────────────────┘
```

## Trigger Conditions

The workflow runs when:
- Push to `main` branch
- Changes in `Frameworks/GomaUI/**`

## Workflow Steps

### 1. Run Snapshot Tests

Ensures all snapshots are up-to-date.

```yaml
- name: Run Snapshot Tests
  run: |
    xcodebuild test \
      -workspace Sportsbook.xcworkspace \
      -scheme GomaUITests \
      -destination 'platform=iOS Simulator,name=iPhone 15 Pro,OS=17.0' \
      -resultBundlePath TestResults.xcresult \
      | xcbeautify --quieter
```

### 2. Generate Enhanced Catalog

Transforms `COMPONENT_MAP.json` into enriched `catalog.json` with:
- Descriptions extracted from README.md files
- Tags inferred from component category and content
- Snapshot file paths mapped to components

```yaml
- name: Generate Catalog JSON
  run: |
    node scripts/generate-catalog.js \
      --input Frameworks/GomaUI/Documentation/COMPONENT_MAP.json \
      --components Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components \
      --snapshots Frameworks/GomaUI/GomaUI/Tests/GomaUITests/SnapshotTests \
      --output Frameworks/GomaUI/Documentation/catalog.json
```

### 3. Sync to Server (Incremental)

Uses SSH + rsync for **incremental transfers** - only changed files are uploaded.

```yaml
- name: Sync to Hetzner
  env:
    HETZNER_SSH_KEY: ${{ secrets.HETZNER_SSH_KEY }}
  run: |
    # Setup SSH
    mkdir -p ~/.ssh
    echo "$HETZNER_SSH_KEY" > ~/.ssh/hetzner
    chmod 600 ~/.ssh/hetzner
    ssh-keyscan -H 136.243.76.42 >> ~/.ssh/known_hosts

    # Sync catalog.json (~500KB, always fast)
    rsync -avz --progress \
      -e "ssh -i ~/.ssh/hetzner" \
      Frameworks/GomaUI/Documentation/catalog.json \
      root@136.243.76.42:/var/www/gomaui-catalog/data/

    # Sync snapshots - ONLY CHANGED FILES
    # rsync compares file size + modification time
    # --checksum adds MD5 verification for extra safety
    rsync -avz --checksum --delete --progress \
      -e "ssh -i ~/.ssh/hetzner" \
      Frameworks/GomaUI/GomaUI/Tests/GomaUITests/SnapshotTests/ \
      root@136.243.76.42:/var/www/gomaui-catalog/public/snapshots/
```

#### How rsync Handles Incremental Updates

| Scenario | Files Transferred |
|----------|-------------------|
| First sync (300 PNGs) | All ~150 MB |
| 2 components changed | Only 2 PNGs ~1 MB |
| No changes | 0 bytes (metadata check only) |
| Component deleted | File removed from server |

The `--checksum` flag ensures even files with same size but different content are detected.
The `--delete` flag removes server files that no longer exist locally.

## Complete Workflow File

`.github/workflows/update-gomaui-catalog.yml`:

```yaml
name: Update GomaUI Catalog

on:
  push:
    branches:
      - main
    paths:
      - 'Frameworks/GomaUI/**'

  # Allow manual trigger
  workflow_dispatch:

jobs:
  update-catalog:
    runs-on: macos-14
    timeout-minutes: 30

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Setup Xcode
        uses: maxim-lobanov/setup-xcode@v1
        with:
          xcode-version: '15.2'

      - name: Install xcbeautify
        run: brew install xcbeautify

      - name: Boot Simulator
        run: |
          xcrun simctl boot "iPhone 15 Pro" || true

      - name: Run Snapshot Tests
        run: |
          xcodebuild test \
            -workspace Sportsbook.xcworkspace \
            -scheme GomaUITests \
            -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
            -resultBundlePath TestResults.xcresult \
            2>&1 | xcbeautify --quieter

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'

      - name: Generate Enhanced Catalog
        run: |
          node scripts/generate-catalog.js

      - name: Setup SSH Key
        env:
          HETZNER_SSH_KEY: ${{ secrets.HETZNER_SSH_KEY }}
        run: |
          mkdir -p ~/.ssh
          echo "$HETZNER_SSH_KEY" > ~/.ssh/hetzner
          chmod 600 ~/.ssh/hetzner
          ssh-keyscan -H 136.243.76.42 >> ~/.ssh/known_hosts

      - name: Sync Catalog Data
        run: |
          rsync -avz --progress \
            -e "ssh -i ~/.ssh/hetzner" \
            Frameworks/GomaUI/Documentation/catalog.json \
            root@136.243.76.42:/var/www/gomaui-catalog/data/

      - name: Sync Snapshots
        run: |
          rsync -avz --delete --progress \
            -e "ssh -i ~/.ssh/hetzner" \
            Frameworks/GomaUI/GomaUI/Tests/GomaUITests/SnapshotTests/ \
            root@136.243.76.42:/var/www/gomaui-catalog/public/snapshots/

      - name: Verify Deployment
        run: |
          ssh -i ~/.ssh/hetzner root@136.243.76.42 \
            "curl -s http://localhost:3013/api/health"
```

## Setup Requirements

### 1. Generate SSH Key Pair

```bash
# On your local machine
ssh-keygen -t ed25519 -C "github-actions-catalog" -f ~/.ssh/github_hetzner_catalog

# This creates:
# ~/.ssh/github_hetzner_catalog (private key - goes to GitHub secrets)
# ~/.ssh/github_hetzner_catalog.pub (public key - goes to server)
```

### 2. Add Public Key to Server

```bash
# Copy public key to server
ssh root@136.243.76.42 "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys" < ~/.ssh/github_hetzner_catalog.pub
```

### 3. Add Private Key to GitHub Secrets

1. Go to Repository Settings → Secrets and variables → Actions
2. Click "New repository secret"
3. Name: `HETZNER_SSH_KEY`
4. Value: Contents of `~/.ssh/github_hetzner_catalog` (private key)

### 4. Verify Server Directory Exists

```bash
ssh root@136.243.76.42 "mkdir -p /var/www/gomaui-catalog/{data,public/snapshots}"
```

## Manual Sync (Development)

For local development or emergency updates:

```bash
# From iOS repo root
./scripts/sync-catalog-manual.sh
```

Script contents:
```bash
#!/bin/bash
set -e

SERVER="root@136.243.76.42"
REMOTE_PATH="/var/www/gomaui-catalog"

echo "Generating catalog..."
node scripts/generate-catalog.js

echo "Syncing catalog.json..."
rsync -avz --progress \
  Frameworks/GomaUI/Documentation/catalog.json \
  $SERVER:$REMOTE_PATH/data/

echo "Syncing snapshots..."
rsync -avz --delete --progress \
  Frameworks/GomaUI/GomaUI/Tests/GomaUITests/SnapshotTests/ \
  $SERVER:$REMOTE_PATH/public/snapshots/

echo "Done! Catalog updated at https://tools.gomademo.com/gomaui-catalog/"
```

## Monitoring

### Workflow Status

Check GitHub Actions tab for workflow runs:
`https://github.com/[org]/[repo]/actions/workflows/update-gomaui-catalog.yml`

### Server Health

```bash
# Check if catalog service is running
ssh root@136.243.76.42 "pm2 status gomaui-catalog"

# Check API health
curl -u user:pass https://tools.gomademo.com/gomaui-catalog/api/health
```

## Troubleshooting

### Workflow fails at SSH step

1. Verify secret `HETZNER_SSH_KEY` is set correctly
2. Check server's `~/.ssh/authorized_keys` has the public key
3. Ensure server allows SSH from GitHub's IP ranges

### Snapshots not updating

1. Check if tests are actually running and passing
2. Verify rsync command is reaching the correct directory
3. Check server disk space: `ssh root@136.243.76.42 "df -h"`

### Catalog shows old data

1. Check if `catalog.json` was generated correctly
2. Verify the Express server reloads data (may need `pm2 restart gomaui-catalog`)
