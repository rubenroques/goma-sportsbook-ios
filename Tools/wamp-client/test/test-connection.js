const WAMPClient = require('../src/wamp-client');
const config = require('../src/config');
const chalk = require('chalk');

async function runTests() {
  console.log(chalk.blue('=== WAMP Client Test Suite ===\n'));
  
  const client = new WAMPClient({
    ...config,
    debug: true
  });

  try {
    // Test 1: Connection
    console.log(chalk.yellow('Test 1: Connection'));
    const connectionResult = await client.connect();
    console.log(chalk.green('✓ Connected successfully'));
    console.log(`  Session ID: ${connectionResult.sessionId}\n`);

    // Test 2: RPC - Get Operator Info
    console.log(chalk.yellow('Test 2: RPC - Get Operator Info'));
    try {
      const operatorInfo = await client.rpc('/sports#operatorInfo');
      console.log(chalk.green('✓ RPC call successful'));
      console.log(`  Operator:`, operatorInfo);
    } catch (error) {
      console.log(chalk.red('✗ RPC failed:', error.message));
    }
    console.log();

    // Test 3: RPC - Get Tournaments
    console.log(chalk.yellow('Test 3: RPC - Get Tournaments'));
    try {
      const tournaments = await client.rpc(
        '/sports#tournaments',
        [],
        { lang: 'en', sportId: '1' }
      );
      console.log(chalk.green('✓ Got tournaments'));
      console.log(`  Count: ${tournaments.length || 0}`);
    } catch (error) {
      console.log(chalk.red('✗ RPC failed:', error.message));
    }
    console.log();

    // Test 4: Subscribe to topic
    console.log(chalk.yellow('Test 4: Subscribe to Live Sports'));
    try {
      const subscription = await client.subscribe(
        '/sports/1/en/disciplines/LIVE/BOTH',
        { 
          duration: 3000,
          maxMessages: 3
        }
      );
      console.log(chalk.green('✓ Subscription successful'));
      console.log(`  Topic: ${subscription.topic}`);
      console.log(`  Messages received: ${subscription.messages ? subscription.messages.length : 0}`);
      console.log(`  Status: ${subscription.status}`);
    } catch (error) {
      console.log(chalk.red('✗ Subscribe failed:', error.message));
    }
    console.log();

    // Test 5: Subscribe with initial dump
    console.log(chalk.yellow('Test 5: Subscribe with Initial Dump'));
    try {
      const subscription = await client.subscribeWithInitialDump(
        '/sports/1/en/popular-matches-aggregator-main/1/10/5',
        { 
          duration: 2000,
          maxMessages: 2
        }
      );
      console.log(chalk.green('✓ Subscription with initial dump successful'));
      console.log(`  Has initial data: ${!!subscription.initialData}`);
      if (subscription.subscription && subscription.subscription.messages) {
        console.log(`  Updates received: ${subscription.subscription.messages.length}`);
      }
    } catch (error) {
      console.log(chalk.red('✗ Subscribe with initial dump failed:', error.message));
    }
    console.log();

    // Test 6: Disconnect
    console.log(chalk.yellow('Test 6: Disconnect'));
    await client.disconnect();
    console.log(chalk.green('✓ Disconnected successfully\n'));

    console.log(chalk.green.bold('=== All tests completed ==='));

  } catch (error) {
    console.error(chalk.red('Test failed:'), error);
    process.exit(1);
  }
}

// Run tests
runTests().catch(console.error);