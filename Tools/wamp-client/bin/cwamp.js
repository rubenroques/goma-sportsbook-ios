#!/usr/bin/env node

const { program } = require('commander');
const chalk = require('chalk');
const WAMPClient = require('../src/wamp-client');
const config = require('../src/config');

// Helper function to parse JSON safely
function parseJSON(str) {
  try {
    return JSON.parse(str);
  } catch (error) {
    console.error(chalk.red('Invalid JSON:', error.message));
    process.exit(1);
  }
}

// Helper function to output results
function outputResult(data, pretty = false) {
  const output = pretty ? JSON.stringify(data, null, 2) : JSON.stringify(data);
  console.log(output);
}

// Main CLI program
program
  .name('cwamp')
  .description('cWAMP - cURL for WAMP protocol (WebSocket Application Messaging Protocol)')
  .version('1.0.0')
  .addHelpText('after', `
${chalk.bold('Examples:')}
  ${chalk.gray('# Test connection to WAMP server')}
  $ cwamp test

  ${chalk.gray('# Make an RPC call to get operator info')}
  $ cwamp rpc -p "/sports#operatorInfo" --pretty

  ${chalk.gray('# Get tournaments with parameters')}
  $ cwamp rpc -p "/sports#tournaments" -k '{"lang":"en","sportId":"1"}'

  ${chalk.gray('# Subscribe to live matches for 5 seconds')}
  $ cwamp subscribe -t "/sports/1/en/live-matches" -d 5000

  ${chalk.gray('# Subscribe with initial dump')}
  $ cwamp subscribe -t "/sports/1/en/popular-matches" --initial-dump

  ${chalk.gray('# Start interactive session')}
  $ cwamp interactive

${chalk.bold('Environment Configuration:')}
  Create a .env file in the tool directory with:
  ${chalk.gray('WAMP_URL')}=wss://sportsapi-betsson-stage.everymatrix.com/v2
  ${chalk.gray('WAMP_CID')}=STAGE_2-STAGE_2r5IxUlPqfCgPlWiXbAJdsHM
  ${chalk.gray('WAMP_REALM')}=www.betsson.cm
  ${chalk.gray('WAMP_DEBUG')}=false

${chalk.bold('Common EveryMatrix RPC Procedures:')}
  ${chalk.cyan('/sports#operatorInfo')}        Get operator information
  ${chalk.cyan('/sports#disciplines')}         Get available sports
  ${chalk.cyan('/sports#tournaments')}         Get tournaments for a sport
  ${chalk.cyan('/sports#popularTournaments')}  Get popular tournaments
  ${chalk.cyan('/sports#matches')}             Get match details
  ${chalk.cyan('/sports#odds')}                Get odds for a match
  ${chalk.cyan('/sports#searchV2')}            Search for events

${chalk.bold('Common Subscription Topics:')}
  ${chalk.cyan('/sports/{op}/{lang}/live-matches-aggregator-main/{sport}/...')}
  ${chalk.cyan('/sports/{op}/{lang}/popular-matches-aggregator-main/{sport}/...')}
  ${chalk.cyan('/sports/{op}/{lang}/{matchId}/match-odds')}
  ${chalk.cyan('/sports/{op}/{lang}/disciplines/LIVE/BOTH')}

${chalk.bold('Sport IDs:')} 1=Football, 2=Tennis, 3=Basketball, 4=Ice Hockey

For more information, see EXAMPLES.md and README.md
`);

// RPC command
program
  .command('rpc')
  .description('Make an RPC call to the WAMP server')
  .requiredOption('-p, --procedure <procedure>', 'RPC procedure to call (e.g., /sports#tournaments)')
  .option('-a, --args <args>', 'Positional arguments as JSON array (rarely used)', '[]')
  .option('-k, --kwargs <kwargs>', 'Keyword arguments as JSON object (main parameters)', '{}')
  .option('--timeout <ms>', 'Timeout in milliseconds', config.timeouts.rpc.toString())
  .option('--url <url>', 'Override WAMP server URL')
  .option('--realm <realm>', 'Override WAMP realm')
  .option('--cid <cid>', 'Override client ID')
  .option('--pretty', 'Pretty print JSON output for readability', false)
  .option('--verbose', 'Enable verbose logging (shows RPC calls/results)', false)
  .option('--debug', 'Enable debug output to see all WAMP messages', false)
  .option('--timestamp', 'Add timestamps to log messages', false)
  .addHelpText('after', `
${chalk.bold('Examples:')}
  ${chalk.gray('# Get operator information (no parameters needed)')}
  $ cwamp rpc -p "/sports#operatorInfo"

  ${chalk.gray('# Get tournaments for football (sportId: 1)')}
  $ cwamp rpc -p "/sports#tournaments" -k '{"lang":"en","sportId":"1"}'

  ${chalk.gray('# Search for Barcelona matches')}
  $ cwamp rpc -p "/sports#searchV2" -k '{"lang":"en","query":"barcelona","limit":5}'

  ${chalk.gray('# Get match details with timeout')}
  $ cwamp rpc -p "/sports#matches" -k '{"lang":"en","matchId":"123"}' --timeout 5000

${chalk.bold('Common Parameters:')}
  ${chalk.cyan('lang')}       Language code (e.g., "en", "fr", "de")
  ${chalk.cyan('sportId')}   Sport identifier (1=Football, 2=Tennis, etc.)
  ${chalk.cyan('matchId')}   Unique match identifier
  ${chalk.cyan('limit')}     Maximum number of results

${chalk.bold('Output Format:')}
  Returns JSON with: { "status": "success", "procedure": "...", "result": {...} }
  Use --pretty for human-readable formatting
`)
  .action(async (options) => {
    // Build config with overrides
    const clientConfig = {
      ...config,
      url: options.url || config.url,
      realm: options.realm || config.realm,
      cid: options.cid || config.cid,
      verbose: options.verbose || config.verbose,
      debug: options.debug || config.debug,
      timestamp: options.timestamp || false
    };
    
    const client = new WAMPClient(clientConfig);

    try {
      // Connect to server
      if (options.debug) {
        console.log(chalk.blue('Connecting to WAMP server...'));
        console.log(chalk.gray(`URL: ${clientConfig.url}`));
        console.log(chalk.gray(`Realm: ${clientConfig.realm}`));
        if (clientConfig.cid) {
          console.log(chalk.gray(`CID: ${clientConfig.cid}`));
        }
      }
      
      await client.connect();
      
      if (options.debug) {
        console.log(chalk.green('Connected successfully'));
      }

      // Parse arguments
      const args = parseJSON(options.args);
      const kwargs = parseJSON(options.kwargs);

      // Make RPC call
      const result = await client.rpc(
        options.procedure,
        args,
        kwargs,
        { timeout: parseInt(options.timeout) }
      );

      // Output result
      outputResult({
        status: 'success',
        procedure: options.procedure,
        result: result
      }, options.pretty);

    } catch (error) {
      outputResult({
        status: 'error',
        error: error.message
      }, options.pretty);
      process.exit(1);
    } finally {
      await client.disconnect();
    }
  });

// Subscribe command
program
  .command('subscribe')
  .description('Subscribe to a WAMP topic and collect messages')
  .requiredOption('-t, --topic <topic>', 'Topic to subscribe to (e.g., /sports/1/en/live-matches)')
  .option('-d, --duration <ms>', 'Duration to listen in milliseconds', config.timeouts.subscription.toString())
  .option('-m, --max-messages <count>', 'Maximum messages to collect before exiting', config.maxSubscriptionMessages.toString())
  .option('--initial-dump', 'Request initial dump before subscribing (EveryMatrix pattern)', false)
  .option('--url <url>', 'Override WAMP server URL')
  .option('--realm <realm>', 'Override WAMP realm')
  .option('--cid <cid>', 'Override client ID')
  .option('--pretty', 'Pretty print JSON output', false)
  .option('--verbose', 'Enable verbose logging', false)
  .option('--debug', 'Enable debug output to see WAMP messages', false)
  .option('--timestamp', 'Add timestamps to log messages', false)
  .addHelpText('after', `
${chalk.bold('Examples:')}
  ${chalk.gray('# Subscribe to live sports for 5 seconds')}
  $ cwamp subscribe -t "/sports/1/en/disciplines/LIVE/BOTH" -d 5000

  ${chalk.gray('# Collect maximum 10 messages from popular matches')}
  $ cwamp subscribe -t "/sports/1/en/popular-matches-aggregator-main/1/10/5" -m 10

  ${chalk.gray('# Subscribe with initial dump (gets current state first)')}
  $ cwamp subscribe -t "/sports/1/en/match-aggregator/123/1" --initial-dump

  ${chalk.gray('# Override connection settings')}
  $ cwamp subscribe -t "/sports/1/en/live" --url "wss://other-server.com/v2" --realm "test.com"

${chalk.bold('Topic Patterns:')}
  ${chalk.cyan('/sports/{operatorId}/{lang}/live-matches-aggregator-main/{sportId}/...')}
    Live matches updates
  
  ${chalk.cyan('/sports/{operatorId}/{lang}/popular-matches-aggregator-main/{sportId}/...')}
    Popular matches updates
  
  ${chalk.cyan('/sports/{operatorId}/{lang}/{matchId}/match-odds')}
    Specific match odds updates

${chalk.bold('Exit Conditions:')}
  The subscription will exit when any of these occur:
  - Duration timeout is reached (--duration)
  - Maximum message count is reached (--max-messages)
  - Connection is lost or error occurs
  - User interrupts with Ctrl+C

${chalk.bold('Output Format:')}
  Returns JSON with collected messages and exit status:
  { "status": "timeout|max_messages_reached", "topic": "...", "messages": [...] }
`)
  .action(async (options) => {
    // Build config with overrides
    const clientConfig = {
      ...config,
      url: options.url || config.url,
      realm: options.realm || config.realm,
      cid: options.cid || config.cid,
      verbose: options.verbose || config.verbose,
      debug: options.debug || config.debug,
      timestamp: options.timestamp || false
    };
    
    const client = new WAMPClient(clientConfig);

    try {
      // Connect to server
      if (options.debug) {
        console.log(chalk.blue('Connecting to WAMP server...'));
        console.log(chalk.gray(`URL: ${clientConfig.url}`));
        console.log(chalk.gray(`Realm: ${clientConfig.realm}`));
        if (clientConfig.cid) {
          console.log(chalk.gray(`CID: ${clientConfig.cid}`));
        }
      }
      
      await client.connect();
      
      if (options.debug) {
        console.log(chalk.green('Connected successfully'));
      }

      let result;
      
      if (options.initialDump) {
        // Subscribe with initial dump
        result = await client.subscribeWithInitialDump(options.topic, {
          duration: parseInt(options.duration),
          maxMessages: parseInt(options.maxMessages)
        });
      } else {
        // Regular subscription
        result = await client.subscribe(options.topic, {
          duration: parseInt(options.duration),
          maxMessages: parseInt(options.maxMessages)
        });
      }

      // Output result
      outputResult({
        status: 'success',
        ...result
      }, options.pretty);

    } catch (error) {
      outputResult({
        status: 'error',
        error: error.message
      }, options.pretty);
      process.exit(1);
    } finally {
      await client.disconnect();
    }
  });

// Register command (WAMP REGISTER/INVOKE pattern for EveryMatrix)
program
  .command('register')
  .description('Register as RPC callee to receive server invocations (EveryMatrix real-time pattern)')
  .requiredOption('-p, --procedure <procedure>', 'Procedure URI to register (e.g., /sports/4093/en/disciplines/LIVE/BOTH)')
  .option('-d, --duration <ms>', 'Duration to listen for invocations in milliseconds', config.timeouts.subscription.toString())
  .option('-m, --max-messages <count>', 'Maximum invocations to collect', config.maxSubscriptionMessages.toString())
  .option('--initial-dump', 'Fetch initial data via RPC before registering', false)
  .option('--url <url>', 'Override WAMP server URL')
  .option('--realm <realm>', 'Override WAMP realm')
  .option('--cid <cid>', 'Override client ID')
  .option('--pretty', 'Pretty print JSON output', false)
  .option('--verbose', 'Enable verbose logging', false)
  .option('--debug', 'Enable debug output', false)
  .option('--timestamp', 'Add timestamps to log messages', false)
  .addHelpText('after', `
${chalk.bold('Why use register instead of subscribe?')}
  EveryMatrix uses the WAMP REGISTER/INVOKE pattern, not pub/sub.
  The client registers a procedure, and the server INVOKEs it with updates.
  This is how the iOS app receives real-time sports data.

${chalk.bold('Examples:')}
  ${chalk.gray('# Register for live sports updates')}
  $ cwamp register -p "/sports/4093/en/disciplines/LIVE/BOTH" -d 30000 --pretty

  ${chalk.gray('# Register with initial dump (like iOS app)')}
  $ cwamp register -p "/sports/4093/en/disciplines/LIVE/BOTH" --initial-dump -d 60000

  ${chalk.gray('# Collect up to 5 invocations')}
  $ cwamp register -p "/sports/4093/en/287742034424664064/match-odds" -m 5 --verbose

${chalk.bold('Output Format:')}
  Returns JSON with invocations received:
  { "status": "timeout|max_messages_reached", "procedure": "...", "invocations": [...] }
`)
  .action(async (options) => {
    const clientConfig = {
      ...config,
      url: options.url || config.url,
      realm: options.realm || config.realm,
      cid: options.cid || config.cid,
      verbose: options.verbose || config.verbose,
      debug: options.debug || config.debug,
      timestamp: options.timestamp || false
    };

    const client = new WAMPClient(clientConfig);

    try {
      if (options.debug) {
        console.log(chalk.blue('Connecting to WAMP server...'));
        console.log(chalk.gray(`URL: ${clientConfig.url}`));
        console.log(chalk.gray(`Realm: ${clientConfig.realm}`));
        if (clientConfig.cid) {
          console.log(chalk.gray(`CID: ${clientConfig.cid}`));
        }
      }

      await client.connect();

      if (options.debug) {
        console.log(chalk.green('Connected successfully'));
      }

      let result = {};

      // Optionally fetch initial dump first
      if (options.initialDump) {
        try {
          const initialData = await client.rpc('/sports#initialDump', [], { topic: options.procedure });
          result.initialData = initialData;
          if (options.debug) {
            console.log(chalk.green('Initial dump received'));
          }
        } catch (error) {
          if (options.verbose) {
            console.log(chalk.yellow(`No initial dump available: ${error.message}`));
          }
        }
      }

      // Register for invocations
      const registration = await client.register(options.procedure, {
        duration: parseInt(options.duration),
        maxMessages: parseInt(options.maxMessages)
      });

      result = { ...result, ...registration };

      outputResult({
        status: 'success',
        ...result
      }, options.pretty);

    } catch (error) {
      outputResult({
        status: 'error',
        error: error.message
      }, options.pretty);
      process.exit(1);
    } finally {
      await client.disconnect();
    }
  });

// Test connection command
program
  .command('test')
  .description('Test connection to WAMP server and verify configuration')
  .option('--url <url>', 'Override WAMP server URL')
  .option('--realm <realm>', 'Override WAMP realm')
  .option('--cid <cid>', 'Override client ID')
  .option('--verbose', 'Enable verbose logging', false)
  .option('--debug', 'Enable debug output', false)
  .option('--timestamp', 'Add timestamps to log messages', false)
  .addHelpText('after', `
${chalk.bold('What this tests:')}
  1. Connection to WAMP server
  2. Authentication and session establishment
  3. Basic RPC call (/sports#operatorInfo)
  4. Clean disconnection

${chalk.bold('Examples:')}
  ${chalk.gray('# Test with default configuration from .env')}
  $ cwamp test

  ${chalk.gray('# Test with different server')}
  $ cwamp test --url "wss://other-server.com/v2" --realm "test.domain.com"

  ${chalk.gray('# Test with debug output')}
  $ cwamp test --debug

${chalk.bold('Success indicators:')}
  ${chalk.green('✓')} Connection successful - WebSocket connected and WAMP session established
  ${chalk.green('✓')} RPC call successful - Server is responding to requests
  ${chalk.green('✓')} Disconnection successful - Clean shutdown

${chalk.bold('Common issues:')}
  ${chalk.red('✗')} Connection failed - Check URL, CID, and network connectivity
  ${chalk.yellow('⚠')} RPC call failed - Connection OK but server may have issues
`)
  .action(async (options) => {
    // Build config with overrides
    const clientConfig = {
      ...config,
      url: options.url || config.url,
      realm: options.realm || config.realm,
      cid: options.cid || config.cid,
      verbose: options.verbose || config.verbose,
      debug: options.debug || config.debug,
      timestamp: options.timestamp || false
    };
    
    const client = new WAMPClient(clientConfig);

    try {
      console.log(chalk.blue('Testing connection to WAMP server...'));
      console.log(chalk.gray(`URL: ${clientConfig.url}`));
      console.log(chalk.gray(`Realm: ${clientConfig.realm}`));
      if (clientConfig.cid) {
        console.log(chalk.gray(`CID: ${clientConfig.cid.substring(0, 20)}...`));
      }
      
      const result = await client.connect();
      
      console.log(chalk.green('✓ Connection successful'));
      console.log(chalk.gray(`Session ID: ${result.sessionId}`));
      
      // Test RPC
      console.log(chalk.blue('Testing RPC call...'));
      try {
        const operatorInfo = await client.rpc('/sports#operatorInfo');
        console.log(chalk.green('✓ RPC call successful'));
      } catch (error) {
        console.log(chalk.yellow('⚠ RPC call failed:', error.message));
      }

      await client.disconnect();
      console.log(chalk.green('✓ Disconnection successful'));
      
    } catch (error) {
      console.log(chalk.red('✗ Connection failed:', error.message));
      process.exit(1);
    }
  });

// Interactive mode command  
program
  .command('interactive')
  .description('Start interactive WAMP session for exploration and testing')
  .option('--url <url>', 'Override WAMP server URL')
  .option('--realm <realm>', 'Override WAMP realm')
  .option('--cid <cid>', 'Override client ID')
  .option('--verbose', 'Enable verbose logging', false)
  .option('--debug', 'Enable debug output', false)
  .option('--timestamp', 'Add timestamps to log messages', false)
  .addHelpText('after', `
${chalk.bold('Interactive Mode Commands:')}
  ${chalk.cyan('rpc <procedure> [args] [kwargs]')}  Make an RPC call
  ${chalk.cyan('subscribe <topic>')}                Subscribe to a topic
  ${chalk.cyan('unsubscribe <topic>')}             Unsubscribe from a topic
  ${chalk.cyan('status')}                          Show connection status
  ${chalk.cyan('help')}                            Show available commands
  ${chalk.cyan('exit')} or ${chalk.cyan('quit')}                    Disconnect and exit

${chalk.bold('Examples in Interactive Mode:')}
  wamp> rpc /sports#operatorInfo
  wamp> rpc /sports#tournaments [] {"lang":"en","sportId":"1"}
  wamp> subscribe /sports/1/en/disciplines/LIVE/BOTH
  wamp> status

${chalk.bold('Features:')}
  - Maintains persistent connection for multiple operations
  - Real-time message display for subscriptions
  - Command history with arrow keys
  - Tab completion (where supported)

${chalk.bold('Use Cases:')}
  - Explore available RPC procedures
  - Test subscription topics
  - Debug connection issues
  - Rapid prototyping of WAMP interactions
`)
  .action(async (options) => {
    const readline = require('readline');
    const rl = readline.createInterface({
      input: process.stdin,
      output: process.stdout,
      prompt: 'wamp> '
    });

    // Build config with overrides
    const clientConfig = {
      ...config,
      url: options.url || config.url,
      realm: options.realm || config.realm,
      cid: options.cid || config.cid,
      verbose: options.verbose || config.verbose,
      debug: options.debug || config.debug,
      timestamp: options.timestamp || false
    };
    
    const client = new WAMPClient(clientConfig);

    console.log(chalk.blue('Connecting to WAMP server...'));
    
    try {
      await client.connect();
      console.log(chalk.green('Connected! Type "help" for commands or "exit" to quit.'));
      
      rl.prompt();
      
      rl.on('line', async (line) => {
        const input = line.trim();
        
        if (input === 'exit' || input === 'quit') {
          await client.disconnect();
          rl.close();
          process.exit(0);
        }
        
        if (input === 'help') {
          console.log('Available commands:');
          console.log('  rpc <procedure> [args] [kwargs] - Make RPC call');
          console.log('  subscribe <topic> - Subscribe to topic');
          console.log('  unsubscribe <topic> - Unsubscribe from topic');
          console.log('  status - Show connection status');
          console.log('  exit - Disconnect and quit');
        } else if (input.startsWith('rpc ')) {
          const parts = input.slice(4).split(' ');
          const procedure = parts[0];
          const args = parts[1] ? parseJSON(parts[1]) : [];
          const kwargs = parts[2] ? parseJSON(parts[2]) : {};
          
          try {
            const result = await client.rpc(procedure, args, kwargs);
            console.log(chalk.green('Result:'), JSON.stringify(result, null, 2));
          } catch (error) {
            console.log(chalk.red('Error:'), error.message);
          }
        } else if (input === 'status') {
          console.log('Connected:', client.isConnected());
          console.log('Subscriptions:', Array.from(client.subscriptions.keys()));
        }
        
        rl.prompt();
      });
      
    } catch (error) {
      console.log(chalk.red('Connection failed:', error.message));
      rl.close();
      process.exit(1);
    }
  });

// Parse arguments
program.parse(process.argv);

// Show help if no command provided
if (!process.argv.slice(2).length) {
  program.outputHelp();
}