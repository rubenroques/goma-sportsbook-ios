require('dotenv').config();

const express = require('express');
const swaggerUi = require('swagger-ui-express');
const YAML = require('yamljs');
const path = require('path');
const ngrok = require('@ngrok/ngrok');
const fs = require('fs');

const app = express();
const port = process.env.PORT || 8080;

// Function to read and parse YAML file
function readYamlFile(filePath) {
    try {
        const fileContents = fs.readFileSync(filePath, 'utf8');
        return YAML.parse(fileContents);
    } catch (e) {
        console.error(`Error reading file ${filePath}:`, e.message);
        return null;
    }
}

// Serve static files from public directory
app.use(express.static(path.join(__dirname, 'public')));

// Load and merge PAM API specifications
console.log('Loading PAM API specifications...');
const pamMainSpec = readYamlFile(path.join(__dirname, 'services/pam/openapi.yaml'));
if (!pamMainSpec) {
    console.error('Failed to load PAM OpenAPI specification');
    process.exit(1);
}

const pamPathFiles = {
    auth: readYamlFile(path.join(__dirname, 'services/pam/paths/auth.yaml')),
    registration: readYamlFile(path.join(__dirname, 'services/pam/paths/registration.yaml')),
    userProfile: readYamlFile(path.join(__dirname, 'services/pam/paths/user-profile.yaml')),
    responsibleGaming: readYamlFile(path.join(__dirname, 'services/pam/paths/responsible-gaming.yaml')),
    financial: readYamlFile(path.join(__dirname, 'services/pam/paths/financial.yaml')),
    bonuses: readYamlFile(path.join(__dirname, 'services/pam/paths/bonuses.yaml')),
    kyc: readYamlFile(path.join(__dirname, 'services/pam/paths/kyc.yaml')),
    support: readYamlFile(path.join(__dirname, 'services/pam/paths/support.yaml')),
    consents: readYamlFile(path.join(__dirname, 'services/pam/paths/consents.yaml')),
    referral: readYamlFile(path.join(__dirname, 'services/pam/paths/referral.yaml')),
};

// Merge paths for PAM API
const mergedPamSpec = {
    ...pamMainSpec,
    paths: {}
};

// Add paths from each PAM file
Object.entries(pamPathFiles).forEach(([name, spec]) => {
    if (spec && spec.paths) {
        console.log(`Adding paths from ${name}`);
        Object.assign(mergedPamSpec.paths, spec.paths);
    } else {
        console.warn(`Warning: No paths found in ${name}`);
    }
});

// Validate that we have paths for PAM
if (Object.keys(mergedPamSpec.paths).length === 0) {
    console.warn('Warning: No paths were loaded for PAM API');
}

// Load and merge Betting API specifications
console.log('\nLoading Betting API specifications...');
const bettingMainSpec = readYamlFile(path.join(__dirname, 'services/betting/openapi.yaml'));
if (!bettingMainSpec) {
    console.error('Failed to load Betting OpenAPI specification');
    process.exit(1);
}

const bettingPathFiles = {
    betManagement: readYamlFile(path.join(__dirname, 'services/betting/paths/bet-management.yaml')),
    betBuilder: readYamlFile(path.join(__dirname, 'services/betting/paths/bet-builder.yaml')),
    boostedBets: readYamlFile(path.join(__dirname, 'services/betting/paths/boosted-bets.yaml')),
    cashout: readYamlFile(path.join(__dirname, 'services/betting/paths/cashout.yaml')),
    betslipSettings: readYamlFile(path.join(__dirname, 'services/betting/paths/betslip-settings.yaml')),
    additionalFeatures: readYamlFile(path.join(__dirname, 'services/betting/paths/additional-features.yaml')),
};

// Merge paths for Betting API
const mergedBettingSpec = {
    ...bettingMainSpec,
    paths: {}
};

// Add paths from each Betting file
Object.entries(bettingPathFiles).forEach(([name, spec]) => {
    if (spec && spec.paths) {
        console.log(`Adding paths from ${name}`);
        // Convert paths to use proper references
        Object.assign(mergedBettingSpec.paths, spec.paths);
    } else {
        console.warn(`Warning: No paths found in ${name}`);
    }
});

// Validate that we have paths for Betting
if (Object.keys(mergedBettingSpec.paths).length === 0) {
    console.warn('Warning: No paths were loaded for Betting API');
}

// Add middleware to log requests to the swagger routes
app.use((req, res, next) => {
    console.log(`${new Date().toISOString()} - ${req.method} ${req.path}`);
    next();
});

// Create separate routers for each API
const pamRouter = express.Router();
const bettingRouter = express.Router();

// Setup PAM documentation
console.log('Setting up PAM documentation route...');
pamRouter.use('/', (req, res, next) => {
    console.log('Inside PAM route handler');
    console.log('PAM Spec Title:', mergedPamSpec.info.title);
    console.log('Request path:', req.path);
    console.log('Total PAM endpoints:', Object.keys(mergedPamSpec.paths).length);
    next();
}, swaggerUi.serveFiles(mergedPamSpec), swaggerUi.setup(mergedPamSpec, {
    explorer: true,
    customSiteTitle: "PAM Omega API Documentation"
}));

// Setup Betting documentation
console.log('Setting up Betting documentation route...');
bettingRouter.use('/', (req, res, next) => {
    console.log('Inside Betting route handler');
    console.log('Betting Spec Title:', mergedBettingSpec.info.title);
    console.log('Request path:', req.path);
    console.log('Total Betting endpoints:', Object.keys(mergedBettingSpec.paths).length);
    next();
}, swaggerUi.serveFiles(mergedBettingSpec), swaggerUi.setup(mergedBettingSpec, {
    explorer: true,
    customSiteTitle: "Betting API Documentation"
}));

// Mount the routers at their respective paths
app.use('/api-docs/pam', pamRouter);
app.use('/api-docs/betting', bettingRouter);

// Root now serves index.html from public directory automatically

app.listen(port, () => {
    console.log('\nServer started successfully!');
    console.log(`Server is running on http://localhost:${port}`);
    console.log(`PAM API docs available on http://localhost:${port}/api-docs/pam`);
    console.log(`Betting API docs available on http://localhost:${port}/api-docs/betting`);
    console.log(`Total PAM endpoints loaded: ${Object.keys(mergedPamSpec.paths).length}`);
    console.log(`Total Betting endpoints loaded: ${Object.keys(mergedBettingSpec.paths).length}`);

    // Get your endpoint online with ngrok
    ngrok.connect({
        addr: port,
        authtoken_from_env: true
    })
    .then(listener => console.log(`NGROK Ingress established at: ${listener.url()}`))
    .catch(err => console.error('Error connecting to ngrok:', err));
});