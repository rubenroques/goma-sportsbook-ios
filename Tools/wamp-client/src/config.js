const path = require('path');
const fs = require('fs');
const os = require('os');
const dotenv = require('dotenv');

// Try to load .env from multiple locations
const possibleEnvPaths = [
  path.join(process.cwd(), '.cwamp.env'),     // Current directory .cwamp.env
  path.join(process.cwd(), '.env'),           // Current directory .env
  path.join(os.homedir(), '.cwamp.env'),      // Home directory .cwamp.env
  path.join(__dirname, '..', '.env')          // Package directory (fallback)
];

// Load the first .env file found
for (const envPath of possibleEnvPaths) {
  if (fs.existsSync(envPath)) {
    dotenv.config({ path: envPath });
    break;
  }
}

const config = {
  // Connection settings
  url: process.env.WAMP_URL || 'wss://sportsapi-betsson-stage.everymatrix.com/v2',
  cid: process.env.WAMP_CID || '',
  realm: process.env.WAMP_REALM || 'www.betsson.cm',
  origin: process.env.WAMP_ORIGIN || 'https://clientsample-sports-stage.everymatrix.com',
  userAgent: process.env.WAMP_USER_AGENT || 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36',
  
  // Timeouts
  timeouts: {
    connection: parseInt(process.env.WAMP_TIMEOUT_CONNECTION || '5000'),
    rpc: parseInt(process.env.WAMP_TIMEOUT_RPC || '10000'),
    subscription: parseInt(process.env.WAMP_TIMEOUT_SUBSCRIPTION || '30000')
  },
  
  // Limits
  maxSubscriptionMessages: parseInt(process.env.WAMP_MAX_SUBSCRIPTION_MESSAGES || '100'),
  
  // Debug
  debug: process.env.WAMP_DEBUG === 'true',
  
  // Authentication (optional)
  auth: process.env.WAMP_AUTH_METHOD ? {
    method: process.env.WAMP_AUTH_METHOD,
    id: process.env.WAMP_AUTH_ID,
    role: process.env.WAMP_AUTH_ROLE
  } : null,
  
  // WAMP role capabilities (EveryMatrix specific)
  roles: {
    caller: {
      features: {
        caller_identification: true,
        call_canceling: true,
        progressive_call_results: true
      }
    },
    callee: {
      features: {
        caller_identification: true,
        pattern_based_registration: true,
        shared_registration: true,
        progressive_call_results: true,
        registration_revocation: true
      }
    },
    publisher: {
      features: {
        publisher_identification: true,
        subscriber_blackwhite_listing: true,
        publisher_exclusion: true
      }
    },
    subscriber: {
      features: {
        publisher_identification: true,
        pattern_based_subscription: true,
        subscription_revocation: true
      }
    }
  }
};

module.exports = config;