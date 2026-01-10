#!/usr/bin/env node

/**
 * Bootstrap Catalog Metadata
 *
 * Generates catalog-metadata.json for the GomaUI Components Catalog.
 * - Reads COMPONENT_MAP.json for component list
 * - Scans folder structure for category mapping
 * - Preserves existing analyzed entries
 * - Adds new components with status: "pending"
 *
 * Usage: node bootstrap-catalog-metadata.js
 */

const fs = require('fs');
const path = require('path');

// Paths relative to GomaUI framework root
const GOMAUI_ROOT = path.resolve(__dirname, '..');
const COMPONENT_MAP_PATH = path.join(GOMAUI_ROOT, 'Documentation', 'COMPONENT_MAP.json');
const METADATA_PATH = path.join(GOMAUI_ROOT, 'Documentation', 'catalog-metadata.json');
const COMPONENTS_DIR = path.join(GOMAUI_ROOT, 'GomaUI', 'Sources', 'GomaUI', 'Components');

// Default empty component template
const EMPTY_COMPONENT = {
  status: "pending",
  displayName: null,
  category: null,
  subcategory: null,
  summary: null,
  description: null,
  complexity: null,
  maturity: null,
  tags: [],
  states: [],
  similarTo: [],
  oftenUsedWith: []
};

// Category definitions with descriptions and subcategories
const CATEGORIES = {
  "Betting": {
    "description": "Components for odds, markets, betslip, and bet placement",
    "subcategories": ["Odds", "Markets", "BetSlip", "Outcomes", "Cashout", "Tickets"]
  },
  "MatchCards": {
    "description": "Match display components in various layouts",
    "subcategories": ["Compact", "Expanded", "Live", "Headers", "Scores"]
  },
  "Navigation": {
    "description": "Tab bars, headers, toolbars, and navigation elements",
    "subcategories": ["TabBars", "Headers", "Toolbars", "Actions"]
  },
  "Forms": {
    "description": "Input fields, text entry, and user data forms",
    "subcategories": ["TextFields", "Selection", "Sliders", "Validation", "Search"]
  },
  "Filters": {
    "description": "Search, filtering, sorting, and selection controls",
    "subcategories": ["Pills", "Sports", "Time", "Leagues", "Options"]
  },
  "Status": {
    "description": "Loading, empty states, notifications, and feedback",
    "subcategories": ["Loading", "Empty", "Notifications", "Progress", "Overlays"]
  },
  "Promotions": {
    "description": "Banners, offers, bonuses, and promotional content",
    "subcategories": ["Banners", "Cards", "Bonuses", "ContentBlocks"]
  },
  "Casino": {
    "description": "Casino game displays, categories, and game cards",
    "subcategories": ["Games", "Categories", "Search", "Grids"]
  },
  "Wallet": {
    "description": "Balance, transactions, deposits, and financial displays",
    "subcategories": ["Balance", "Transactions", "Deposits", "Limits"]
  },
  "Profile": {
    "description": "User profile, settings, and account management",
    "subcategories": ["Menu", "Settings", "Language", "Sharing"]
  },
  "UIElements": {
    "description": "Basic UI building blocks and utility components",
    "subcategories": ["Buttons", "Labels", "Rows", "Expandable", "Misc"]
  }
};

// Components to exclude (utilities, not UI components)
const EXCLUDED_COMPONENTS = [
  'Shared',
  'StyleProvider',
  'HelperViews'
];

/**
 * Scan the Components folder to build a category map
 */
function buildCategoryMap() {
  const categoryMap = {};

  // Scan top-level categories
  const categories = fs.readdirSync(COMPONENTS_DIR, { withFileTypes: true })
    .filter(d => d.isDirectory())
    .map(d => d.name);

  for (const category of categories) {
    if (EXCLUDED_COMPONENTS.includes(category)) continue;

    const categoryPath = path.join(COMPONENTS_DIR, category);
    const items = fs.readdirSync(categoryPath, { withFileTypes: true })
      .filter(d => d.isDirectory());

    for (const item of items) {
      // Check if it's a component (has .swift files) or a subcategory
      const itemPath = path.join(categoryPath, item.name);
      const hasSwiftFiles = fs.readdirSync(itemPath).some(f => f.endsWith('.swift'));

      if (hasSwiftFiles) {
        // It's a component
        categoryMap[item.name] = { category, subcategory: null };
      } else {
        // It's a subcategory (like ContentBlocks)
        const subItems = fs.readdirSync(itemPath, { withFileTypes: true })
          .filter(d => d.isDirectory());

        for (const subItem of subItems) {
          categoryMap[subItem.name] = { category, subcategory: item.name };
        }
      }
    }
  }

  return categoryMap;
}

/**
 * Main bootstrap function
 */
function bootstrap() {
  console.log('GomaUI Catalog Metadata Bootstrap');
  console.log('==================================\n');

  // Read component map
  if (!fs.existsSync(COMPONENT_MAP_PATH)) {
    console.error(`Error: COMPONENT_MAP.json not found at ${COMPONENT_MAP_PATH}`);
    process.exit(1);
  }

  const componentMap = JSON.parse(fs.readFileSync(COMPONENT_MAP_PATH, 'utf8'));
  console.log(`Found ${Object.keys(componentMap).length} components in COMPONENT_MAP.json`);

  // Build category map from folder structure
  const categoryMap = buildCategoryMap();
  console.log(`Mapped ${Object.keys(categoryMap).length} components to categories from folder structure\n`);

  // Read existing metadata or create new
  let metadata;
  let existingCount = 0;

  if (fs.existsSync(METADATA_PATH)) {
    metadata = JSON.parse(fs.readFileSync(METADATA_PATH, 'utf8'));
    existingCount = Object.keys(metadata.components || {}).length;
    console.log(`Existing catalog-metadata.json found with ${existingCount} components`);
  } else {
    metadata = {
      version: "1.0.0",
      generated: new Date().toISOString(),
      featured: [],
      categories: CATEGORIES,
      components: {}
    };
    console.log('Creating new catalog-metadata.json');
  }

  // Ensure categories are up to date
  metadata.categories = CATEGORIES;

  // Process each component
  let added = 0;
  let updated = 0;
  let skipped = 0;

  for (const componentName of Object.keys(componentMap)) {
    // Skip excluded components
    if (EXCLUDED_COMPONENTS.includes(componentName)) {
      skipped++;
      continue;
    }

    const categoryInfo = categoryMap[componentName] || { category: null, subcategory: null };

    if (!metadata.components[componentName]) {
      // New component - add with pending status
      metadata.components[componentName] = {
        ...EMPTY_COMPONENT,
        category: categoryInfo.category,
        subcategory: categoryInfo.subcategory
      };
      added++;
    } else {
      // Existing component - update category if it was null
      const existing = metadata.components[componentName];
      if (existing.category === null && categoryInfo.category) {
        existing.category = categoryInfo.category;
        updated++;
      }
      if (existing.subcategory === null && categoryInfo.subcategory) {
        existing.subcategory = categoryInfo.subcategory;
        updated++;
      }
    }
  }

  // Sort components alphabetically
  const sortedComponents = {};
  Object.keys(metadata.components).sort().forEach(key => {
    sortedComponents[key] = metadata.components[key];
  });
  metadata.components = sortedComponents;

  // Update timestamp
  metadata.generated = new Date().toISOString();

  // Write output
  fs.writeFileSync(METADATA_PATH, JSON.stringify(metadata, null, 2));

  // Generate statistics
  const components = Object.values(metadata.components);
  const byStatus = {
    pending: components.filter(c => c.status === 'pending').length,
    partial: components.filter(c => c.status === 'partial').length,
    complete: components.filter(c => c.status === 'complete').length
  };

  const byCategory = {};
  components.forEach(c => {
    const cat = c.category || 'Uncategorized';
    byCategory[cat] = (byCategory[cat] || 0) + 1;
  });

  // Report
  console.log('\n--- Results ---');
  console.log(`Total components: ${Object.keys(metadata.components).length}`);
  console.log(`Added: ${added}`);
  console.log(`Updated: ${updated}`);
  console.log(`Skipped (utilities): ${skipped}`);

  console.log('\n--- By Status ---');
  console.log(`Pending: ${byStatus.pending}`);
  console.log(`Partial: ${byStatus.partial}`);
  console.log(`Complete: ${byStatus.complete}`);

  console.log('\n--- By Category ---');
  Object.entries(byCategory).sort((a, b) => b[1] - a[1]).forEach(([cat, count]) => {
    console.log(`${cat}: ${count}`);
  });

  console.log(`\nOutput written to: ${METADATA_PATH}`);
}

// Run
bootstrap();
