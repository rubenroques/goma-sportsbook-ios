const chalk = require('chalk');

class Logger {
  constructor(options = {}) {
    this.debugEnabled = options.debug || false;
    this.verboseEnabled = options.verbose || false;
    this.silent = options.silent || false;
    this.timestampEnabled = options.timestamp || false;
  }

  /**
   * Get timestamp string
   */
  getTimestamp() {
    if (!this.timestampEnabled) return '';
    const now = new Date();
    return chalk.gray(`[${now.toISOString()}] `);
  }

  /**
   * Log levels
   */
  
  error(message, details = null) {
    if (this.silent) return;
    console.error(
      this.getTimestamp() + 
      chalk.red('ERROR: ') + 
      message
    );
    if (details && this.verboseEnabled) {
      console.error(chalk.red(JSON.stringify(details, null, 2)));
    }
  }

  warn(message, details = null) {
    if (this.silent) return;
    console.warn(
      this.getTimestamp() + 
      chalk.yellow('WARN: ') + 
      message
    );
    if (details && this.verboseEnabled) {
      console.warn(chalk.yellow(JSON.stringify(details, null, 2)));
    }
  }

  info(message, details = null) {
    if (this.silent) return;
    console.log(
      this.getTimestamp() + 
      chalk.blue('INFO: ') + 
      message
    );
    if (details && this.verboseEnabled) {
      console.log(chalk.gray(JSON.stringify(details, null, 2)));
    }
  }

  success(message, details = null) {
    if (this.silent) return;
    console.log(
      this.getTimestamp() + 
      chalk.green('✓ ') + 
      message
    );
    if (details && this.verboseEnabled) {
      console.log(chalk.green(JSON.stringify(details, null, 2)));
    }
  }

  debug(message, details = null) {
    if (!this.debugEnabled || this.silent) return;
    console.log(
      this.getTimestamp() + 
      chalk.gray('DEBUG: ') + 
      chalk.gray(message)
    );
    if (details) {
      console.log(chalk.gray(JSON.stringify(details, null, 2)));
    }
  }

  verbose(message, details = null) {
    if (!this.verboseEnabled || this.silent) return;
    console.log(
      this.getTimestamp() + 
      chalk.cyan('VERBOSE: ') + 
      message
    );
    if (details) {
      console.log(chalk.cyan(JSON.stringify(details, null, 2)));
    }
  }

  /**
   * WAMP-specific logging
   */
  
  wampMessage(direction, message) {
    if (!this.debugEnabled) return;
    
    const arrow = direction === 'sent' ? '→' : '←';
    const color = direction === 'sent' ? chalk.magenta : chalk.cyan;
    
    console.log(
      this.getTimestamp() +
      color(`WAMP ${arrow} `) +
      chalk.gray(JSON.stringify(message))
    );
  }

  rpcCall(procedure, args, kwargs) {
    if (!this.verboseEnabled) return;
    
    console.log(
      this.getTimestamp() +
      chalk.magenta('RPC → ') +
      chalk.white(procedure)
    );
    
    if (this.debugEnabled) {
      if (args && args.length > 0) {
        console.log(chalk.gray('  Args: ') + chalk.gray(JSON.stringify(args)));
      }
      if (kwargs && Object.keys(kwargs).length > 0) {
        console.log(chalk.gray('  Kwargs: ') + chalk.gray(JSON.stringify(kwargs)));
      }
    }
  }

  rpcResult(procedure, result) {
    if (!this.verboseEnabled) return;
    
    console.log(
      this.getTimestamp() +
      chalk.cyan('RPC ← ') +
      chalk.white(procedure)
    );
    
    if (this.debugEnabled && result) {
      const preview = JSON.stringify(result).substring(0, 200);
      console.log(chalk.gray('  Result: ') + chalk.gray(preview + '...'));
    }
  }

  subscription(action, topic, details = null) {
    if (!this.verboseEnabled) return;
    
    const icons = {
      'subscribe': '📡',
      'unsubscribe': '🔕',
      'event': '📨',
      'error': '❌'
    };
    
    const icon = icons[action] || '•';
    
    console.log(
      this.getTimestamp() +
      chalk.yellow(`${icon} ${action.toUpperCase()}: `) +
      chalk.white(topic)
    );
    
    if (details && this.debugEnabled) {
      console.log(chalk.gray(JSON.stringify(details, null, 2)));
    }
  }

  /**
   * Connection status
   */
  
  connectionStatus(status, details = null) {
    const statusColors = {
      'connecting': chalk.yellow,
      'connected': chalk.green,
      'disconnected': chalk.red,
      'error': chalk.red,
      'reconnecting': chalk.yellow
    };
    
    const color = statusColors[status] || chalk.white;
    
    console.log(
      this.getTimestamp() +
      color(`CONNECTION: ${status.toUpperCase()}`)
    );
    
    if (details && this.verboseEnabled) {
      console.log(chalk.gray(JSON.stringify(details, null, 2)));
    }
  }

  /**
   * Progress indicators
   */
  
  startProgress(message) {
    if (this.silent) return;
    process.stdout.write(
      this.getTimestamp() +
      chalk.blue('⏳ ') +
      message + '...'
    );
  }

  endProgress(success = true, message = '') {
    if (this.silent) return;
    if (success) {
      console.log(chalk.green(' ✓') + (message ? ' ' + message : ''));
    } else {
      console.log(chalk.red(' ✗') + (message ? ' ' + message : ''));
    }
  }

  /**
   * Table output for structured data
   */
  
  table(data, columns = null) {
    if (this.silent) return;
    
    if (!columns && data.length > 0) {
      columns = Object.keys(data[0]);
    }
    
    // Simple ASCII table
    const widths = {};
    columns.forEach(col => {
      widths[col] = Math.max(
        col.length,
        ...data.map(row => String(row[col] || '').length)
      );
    });
    
    // Header
    const header = columns.map(col => 
      col.padEnd(widths[col])
    ).join(' | ');
    
    console.log(chalk.bold(header));
    console.log(chalk.gray('-'.repeat(header.length)));
    
    // Rows
    data.forEach(row => {
      const line = columns.map(col => 
        String(row[col] || '').padEnd(widths[col])
      ).join(' | ');
      console.log(line);
    });
  }

  /**
   * Create child logger with inherited settings
   */
  
  child(prefix) {
    const childLogger = new Logger({
      debug: this.debugEnabled,
      verbose: this.verboseEnabled,
      silent: this.silent,
      timestamp: this.timestampEnabled
    });
    
    // Override methods to add prefix
    const methods = ['error', 'warn', 'info', 'success', 'debug', 'verbose'];
    methods.forEach(method => {
      const original = childLogger[method].bind(childLogger);
      childLogger[method] = (message, ...args) => {
        original(`[${prefix}] ${message}`, ...args);
      };
    });
    
    return childLogger;
  }
}

module.exports = Logger;