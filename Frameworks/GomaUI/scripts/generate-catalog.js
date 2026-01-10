#!/usr/bin/env node

/**
 * GomaUI Catalog Generator
 *
 * Merges all data sources into a single catalog.json for the web catalog:
 * - catalog-metadata.json (rich component metadata)
 * - COMPONENT_MAP.json (parent/child relationships)
 * - Snapshot PNGs (visual references)
 * - README.md files (documentation)
 *
 * Usage: node generate-catalog.js
 */

const fs = require('fs');
const path = require('path');

// === CONFIGURATION ===
const GOMAUI_ROOT = path.resolve(__dirname, '..');
const PATHS = {
  componentMap: path.join(GOMAUI_ROOT, 'Documentation', 'COMPONENT_MAP.json'),
  catalogMetadata: path.join(GOMAUI_ROOT, 'Documentation', 'catalog-metadata.json'),
  snapshotsDir: path.join(GOMAUI_ROOT, 'GomaUI', 'Tests', 'GomaUITests', 'SnapshotTests'),
  componentsDir: path.join(GOMAUI_ROOT, 'GomaUI', 'Sources', 'GomaUI', 'Components'),
  output: path.join(GOMAUI_ROOT, 'Documentation', 'catalog.json')
};

const EXCLUDED_COMPONENTS = ['Shared', 'StyleProvider', 'HelperViews'];

// Featured components for homepage showcase
const FEATURED_COMPONENTS = [
  'OutcomeItemView',
  'ButtonView',
  'MatchHeaderCompactView',
  'TallOddsMatchCardView',
  'CasinoGameCardView',
  'BetslipTicketView',
  'WalletDetailView',
  'BorderedTextFieldView'
];

/**
 * Scan snapshot directory for a component
 * Returns array of { category, light, dark } objects
 */
function scanSnapshots(componentName) {
  const componentSnapshotDir = path.join(PATHS.snapshotsDir, componentName);

  if (!fs.existsSync(componentSnapshotDir)) {
    return [];
  }

  const snapshotsSubDir = path.join(componentSnapshotDir, '__Snapshots__', `${componentName}SnapshotTests`);

  if (!fs.existsSync(snapshotsSubDir)) {
    return [];
  }

  const files = fs.readdirSync(snapshotsSubDir).filter(f => f.endsWith('.png'));

  // Group by category (extract from filename pattern: test{Component}_{Category}_{Light|Dark}.1.png)
  // Also handle legacy pattern without theme: test{Component}_{Category}.1.png
  const categoryMap = new Map();

  for (const file of files) {
    // Pattern: test{ComponentName}_{Category}_{Light|Dark}.1.png
    // Or: test{ComponentName}_{Category}.1.png (legacy)
    const match = file.match(/^test[^_]+_([^_]+)(?:_(Light|Dark))?\.1\.png$/);

    if (match) {
      const category = match[1];
      const theme = match[2] || 'Light'; // Default to Light for legacy files

      if (!categoryMap.has(category)) {
        categoryMap.set(category, { category, light: null, dark: null });
      }

      const relativePath = `${componentName}/__Snapshots__/${componentName}SnapshotTests/${file}`;

      if (theme === 'Light') {
        categoryMap.get(category).light = relativePath;
      } else {
        categoryMap.get(category).dark = relativePath;
      }
    }
  }

  return Array.from(categoryMap.values());
}

/**
 * Find README content for a component
 * Searches multiple possible locations
 */
function findReadmeContent(componentName, category, subcategory) {
  const searchPaths = [];

  // Build search paths based on category/subcategory
  if (category && subcategory) {
    searchPaths.push(
      path.join(PATHS.componentsDir, category, subcategory, componentName, 'Documentation', 'README.md'),
      path.join(PATHS.componentsDir, category, subcategory, componentName, 'README.md')
    );
  }

  if (category) {
    searchPaths.push(
      path.join(PATHS.componentsDir, category, componentName, 'Documentation', 'README.md'),
      path.join(PATHS.componentsDir, category, componentName, 'README.md')
    );
  }

  // Try each path
  for (const readmePath of searchPaths) {
    if (fs.existsSync(readmePath)) {
      try {
        return fs.readFileSync(readmePath, 'utf8');
      } catch {
        continue;
      }
    }
  }

  return null;
}

/**
 * Main catalog generation function
 */
function generateCatalog() {
  console.log('GomaUI Catalog Generator');
  console.log('========================\n');

  // === Load Data Sources ===

  // 1. Load COMPONENT_MAP.json
  if (!fs.existsSync(PATHS.componentMap)) {
    console.error(`Error: COMPONENT_MAP.json not found at ${PATHS.componentMap}`);
    process.exit(1);
  }
  const componentMap = JSON.parse(fs.readFileSync(PATHS.componentMap, 'utf8'));
  console.log(`Loaded COMPONENT_MAP.json: ${Object.keys(componentMap).length} components`);

  // 2. Load catalog-metadata.json
  if (!fs.existsSync(PATHS.catalogMetadata)) {
    console.error(`Error: catalog-metadata.json not found at ${PATHS.catalogMetadata}`);
    process.exit(1);
  }
  const catalogMetadata = JSON.parse(fs.readFileSync(PATHS.catalogMetadata, 'utf8'));
  console.log(`Loaded catalog-metadata.json: ${Object.keys(catalogMetadata.components).length} components`);

  // === Build Catalog ===

  const catalog = {
    version: '1.0.0',
    generated: new Date().toISOString(),
    featured: FEATURED_COMPONENTS.filter(name => catalogMetadata.components[name]),
    categories: catalogMetadata.categories,
    statistics: {
      totalComponents: 0,
      withSnapshots: 0,
      withReadme: 0,
      byCategory: {},
      byComplexity: {},
      byMaturity: {}
    },
    components: {}
  };

  // Process each component
  let processedCount = 0;
  let snapshotCount = 0;
  let readmeCount = 0;

  for (const componentName of Object.keys(catalogMetadata.components)) {
    // Skip excluded
    if (EXCLUDED_COMPONENTS.includes(componentName)) {
      continue;
    }

    const metadata = catalogMetadata.components[componentName];
    const mapData = componentMap[componentName] || {};

    // Scan for snapshots
    const snapshots = scanSnapshots(componentName);
    if (snapshots.length > 0) {
      snapshotCount++;
    }

    // Find README
    const readmeContent = findReadmeContent(componentName, metadata.category, metadata.subcategory);
    if (readmeContent) {
      readmeCount++;
    }

    // Merge all data
    catalog.components[componentName] = {
      // From catalog-metadata.json
      displayName: metadata.displayName || componentName,
      category: metadata.category,
      subcategory: metadata.subcategory,
      summary: metadata.summary,
      description: metadata.description,
      complexity: metadata.complexity,
      maturity: metadata.maturity,
      tags: metadata.tags || [],
      states: metadata.states || [],
      similarTo: metadata.similarTo || [],
      oftenUsedWith: metadata.oftenUsedWith || [],

      // From COMPONENT_MAP.json
      parents: mapData.parents || [],
      children: mapData.children || [],
      has_readme: mapData.has_readme || false,
      has_snapshot_tests: mapData.has_snapshot_tests || false,

      // Generated
      readme_content: readmeContent,
      snapshots: snapshots
    };

    processedCount++;

    // Update statistics
    const cat = metadata.category || 'Uncategorized';
    catalog.statistics.byCategory[cat] = (catalog.statistics.byCategory[cat] || 0) + 1;

    if (metadata.complexity) {
      catalog.statistics.byComplexity[metadata.complexity] =
        (catalog.statistics.byComplexity[metadata.complexity] || 0) + 1;
    }

    if (metadata.maturity) {
      catalog.statistics.byMaturity[metadata.maturity] =
        (catalog.statistics.byMaturity[metadata.maturity] || 0) + 1;
    }
  }

  // Finalize statistics
  catalog.statistics.totalComponents = processedCount;
  catalog.statistics.withSnapshots = snapshotCount;
  catalog.statistics.withReadme = readmeCount;

  // Sort components alphabetically
  const sortedComponents = {};
  Object.keys(catalog.components).sort().forEach(key => {
    sortedComponents[key] = catalog.components[key];
  });
  catalog.components = sortedComponents;

  // === Write Output ===
  fs.writeFileSync(PATHS.output, JSON.stringify(catalog, null, 2));

  // === Report ===
  console.log('\n--- Generation Complete ---');
  console.log(`Total components: ${processedCount}`);
  console.log(`With snapshots: ${snapshotCount}`);
  console.log(`With README: ${readmeCount}`);
  console.log(`Featured: ${catalog.featured.length}`);

  console.log('\n--- By Category ---');
  Object.entries(catalog.statistics.byCategory)
    .sort((a, b) => b[1] - a[1])
    .forEach(([cat, count]) => {
      console.log(`  ${cat}: ${count}`);
    });

  console.log('\n--- By Complexity ---');
  Object.entries(catalog.statistics.byComplexity)
    .forEach(([complexity, count]) => {
      console.log(`  ${complexity}: ${count}`);
    });

  console.log(`\nOutput written to: ${PATHS.output}`);

  // Calculate file size
  const stats = fs.statSync(PATHS.output);
  const fileSizeKB = (stats.size / 1024).toFixed(1);
  console.log(`File size: ${fileSizeKB} KB`);
}

// Run
generateCatalog();
