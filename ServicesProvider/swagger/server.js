const express = require('express');
const swaggerUi = require('swagger-ui-express');
const fs = require('fs');
const yaml = require('js-yaml');
const path = require('path');

const app = express();
const port = 3000;

// Function to read and parse YAML file
function readYamlFile(filePath) {
    try {
        const fileContents = fs.readFileSync(filePath, 'utf8');
        return yaml.load(fileContents);
    } catch (e) {
        console.error(`Error reading file ${filePath}:`, e.message);
        return null;
    }
}

// Read all YAML files
console.log('Loading OpenAPI specifications...');

const mainSpec = readYamlFile(path.join(__dirname, 'openapi.yaml'));
if (!mainSpec) {
    console.error('Failed to load main OpenAPI specification');
    process.exit(1);
}

const pathFiles = {
    auth: readYamlFile(path.join(__dirname, 'paths/auth.yaml')),
    registration: readYamlFile(path.join(__dirname, 'paths/registration.yaml')),
    userProfile: readYamlFile(path.join(__dirname, 'paths/user-profile.yaml')),
    responsibleGaming: readYamlFile(path.join(__dirname, 'paths/responsible-gaming.yaml')),
    financial: readYamlFile(path.join(__dirname, 'paths/financial.yaml')),
    bonuses: readYamlFile(path.join(__dirname, 'paths/bonuses.yaml')),
    kyc: readYamlFile(path.join(__dirname, 'paths/kyc.yaml')),
    support: readYamlFile(path.join(__dirname, 'paths/support.yaml')),
    consents: readYamlFile(path.join(__dirname, 'paths/consents.yaml')),
    referral: readYamlFile(path.join(__dirname, 'paths/referral.yaml')),
};

// Merge paths
const mergedSpec = {
    ...mainSpec,
    paths: {}
};

// Add paths from each file
Object.entries(pathFiles).forEach(([name, spec]) => {
    if (spec && spec.paths) {
        console.log(`Adding paths from ${name}`);
        Object.assign(mergedSpec.paths, spec.paths);
    } else {
        console.warn(`Warning: No paths found in ${name}`);
    }
});

// Validate that we have paths
if (Object.keys(mergedSpec.paths).length === 0) {
    console.warn('Warning: No paths were loaded from any file');
}

// Serve Swagger UI
app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(mergedSpec));

// Redirect root to docs
app.get('/', (req, res) => {
    res.redirect('/api-docs');
});

app.listen(port, () => {
    console.log(`Swagger UI is available at http://localhost:${port}/api-docs`);
    console.log(`Total endpoints loaded: ${Object.keys(mergedSpec.paths).length}`);
});