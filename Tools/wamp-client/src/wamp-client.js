const autobahn = require('autobahn');
const { MessageFormatter } = require('./message-formatter');
const Logger = require('./logger');

class WAMPClient {
  constructor(config) {
    this.config = config;
    this.connection = null;
    this.session = null;
    this.subscriptions = new Map();
    this.pendingRequests = new Map();
    this.messageFormatter = new MessageFormatter(config);
    this.isInitialized = false;
    
    // Initialize logger
    this.logger = new Logger({
      debug: config.debug || false,
      verbose: config.verbose || false,
      timestamp: config.timestamp || false
    });
  }

  /**
   * Connect to WAMP server
   */
  async connect(options = {}) {
    // Build URL with CID if provided
    let url = options.url || this.config.url;
    const cid = options.cid || this.config.cid;
    if (cid) {
      url = `${url}?cid=${cid}`;
    }
    
    const connectionConfig = {
      url: url,
      realm: options.realm || this.config.realm,
      retry_if_unreachable: false,
      max_retries: 0,
      initial_retry_delay: 1,
      // Add custom headers for EveryMatrix
      headers: {
        'Origin': this.config.origin,
        'User-Agent': this.config.userAgent
      }
    };

    if (this.config.auth) {
      connectionConfig.authmethods = [this.config.auth.method];
      connectionConfig.authid = this.config.auth.id;
      connectionConfig.authrole = this.config.auth.role;
    }

    return new Promise((resolve, reject) => {
      const timeout = setTimeout(() => {
        reject(new Error(`Connection timeout after ${this.config.timeouts.connection}ms`));
      }, this.config.timeouts.connection);

      this.connection = new autobahn.Connection(connectionConfig);

      this.connection.onopen = async (session, details) => {
        clearTimeout(timeout);
        this.session = session;
        
        this.logger.connectionStatus('connected', { sessionId: session.id });
        this.logger.debug('Session details', details);

        try {
          // Skip initialization for now, just mark as connected
          // await this.initializeSession();
          this.isInitialized = true;
          
          resolve({
            status: 'connected',
            sessionId: session.id,
            details: details
          });
        } catch (error) {
          reject(error);
        }
      };

      this.connection.onclose = (reason, details) => {
        clearTimeout(timeout);
        
        this.logger.connectionStatus('disconnected', { reason, details });
        
        this.session = null;
        this.isInitialized = false;
        
        if (!this.session) {
          reject(new Error(`Connection failed: ${reason}`));
        }
      };

      this.connection.open();
    });
  }

  /**
   * Initialize EveryMatrix session with required messages
   */
  async initializeSession() {
    this.logger.verbose('Initializing EveryMatrix session...');

    try {
      // Send initial session setup messages
      const sessionInfo = await this.rpc('/user#getSessionInfo');
      this.logger.debug('Session info', sessionInfo);

      const clientIdentity = await this.rpc('/connection#getClientIdentity');
      this.logger.debug('Client identity', clientIdentity);

      // Subscribe to required topics
      await this.subscribe('/sessionStateChange', { internal: true });
      await this.subscribe('/registrationDismissed', { internal: true });

      this.logger.success('EveryMatrix session initialized');
    } catch (error) {
      this.logger.error('Failed to initialize EveryMatrix session', error);
      throw error;
    }
  }

  /**
   * Make an RPC call
   */
  async rpc(procedure, args = [], kwargs = {}, options = {}) {
    if (!this.session) {
      throw new Error('Not connected to WAMP server');
    }

    const timeout = options.timeout || this.config.timeouts.rpc;

    return new Promise((resolve, reject) => {
      const timeoutHandle = setTimeout(() => {
        reject(new Error(`RPC call timeout after ${timeout}ms`));
      }, timeout);

      this.logger.rpcCall(procedure, args, kwargs);

      this.session.call(procedure, args, kwargs).then(
        (result) => {
          clearTimeout(timeoutHandle);
          
          this.logger.rpcResult(procedure, result);
          
          resolve(result);
        },
        (error) => {
          clearTimeout(timeoutHandle);
          
          this.logger.error(`RPC error for ${procedure}`, error);
          
          reject(error);
        }
      );
    });
  }

  /**
   * Subscribe to a topic with optional message collection
   */
  async subscribe(topic, options = {}) {
    if (!this.session) {
      throw new Error('Not connected to WAMP server');
    }

    const messages = [];
    const startTime = Date.now();
    const duration = options.duration || this.config.timeouts.subscription;
    const maxMessages = options.maxMessages || this.config.maxSubscriptionMessages;
    const collectMessages = !options.internal;

    return new Promise((resolve, reject) => {
      let timeoutHandle;
      let subscription;

      const cleanup = () => {
        if (timeoutHandle) {
          clearTimeout(timeoutHandle);
        }
        if (subscription && !options.keepAlive) {
          this.session.unsubscribe(subscription);
          this.subscriptions.delete(topic);
        }
      };

      const handleEvent = (args, kwargs, details) => {
        this.logger.subscription('event', topic, { args, kwargs, details });

        if (collectMessages) {
          const message = {
            timestamp: Date.now(),
            args: args || [],
            kwargs: kwargs || {},
            details: details || {}
          };
          messages.push(message);

          // Check message limit
          if (maxMessages && messages.length >= maxMessages) {
            cleanup();
            resolve({
              topic,
              messages,
              status: 'max_messages_reached',
              duration: Date.now() - startTime
            });
          }
        }

        // Call custom handler if provided
        if (options.onEvent) {
          options.onEvent(args, kwargs, details);
        }
      };

      // Set timeout for message collection
      if (collectMessages && duration) {
        timeoutHandle = setTimeout(() => {
          cleanup();
          resolve({
            topic,
            messages,
            status: 'timeout',
            duration: duration
          });
        }, duration);
      }

      this.logger.subscription('subscribe', topic);

      this.session.subscribe(topic, handleEvent).then(
        (sub) => {
          subscription = sub;
          this.subscriptions.set(topic, subscription);
          
          this.logger.success(`Subscribed to ${topic}`, { subscriptionId: sub.id });

          // If this is an internal subscription or keepAlive, resolve immediately
          if (options.internal || options.keepAlive) {
            resolve({
              topic,
              subscriptionId: sub.id,
              status: 'subscribed'
            });
          }
          // Otherwise wait for messages/timeout
        },
        (error) => {
          clearTimeout(timeoutHandle);
          
          this.logger.error(`Subscribe error for ${topic}`, error);
          
          reject(error);
        }
      );
    });
  }

  /**
   * Subscribe with initial dump (EveryMatrix pattern)
   */
  async subscribeWithInitialDump(topic, options = {}) {
    try {
      // First, request initial dump
      let initialData = null;
      
      try {
        initialData = await this.rpc('/sports#initialDump', [], { topic });
        
        this.logger.debug(`Initial dump for ${topic}`, initialData);
      } catch (error) {
        this.logger.verbose(`No initial dump available for ${topic}`);
      }

      // Then subscribe for updates
      const subscription = await this.subscribe(topic, options);

      return {
        topic,
        initialData,
        subscription,
        status: 'subscribed_with_initial'
      };
    } catch (error) {
      throw new Error(`Failed to subscribe with initial dump: ${error.message}`);
    }
  }

  /**
   * Unsubscribe from a topic
   */
  async unsubscribe(topic) {
    const subscription = this.subscriptions.get(topic);
    
    if (!subscription) {
      throw new Error(`Not subscribed to topic: ${topic}`);
    }

    if (!this.session) {
      throw new Error('Not connected to WAMP server');
    }

    await this.session.unsubscribe(subscription);
    this.subscriptions.delete(topic);
    
    this.logger.subscription('unsubscribe', topic);

    return { topic, status: 'unsubscribed' };
  }

  /**
   * Disconnect from WAMP server
   */
  async disconnect() {
    if (this.connection && this.connection.isOpen) {
      // Unsubscribe from all topics
      for (const [topic, subscription] of this.subscriptions) {
        try {
          await this.session.unsubscribe(subscription);
        } catch (error) {
          this.logger.error(`Error unsubscribing from ${topic}`, error);
        }
      }
      
      this.subscriptions.clear();
      this.connection.close();
      
      this.logger.connectionStatus('disconnected');
    }
    
    this.session = null;
    this.isInitialized = false;
  }

  /**
   * Check if connected
   */
  isConnected() {
    return this.session !== null && this.connection && this.connection.isOpen;
  }
}

module.exports = WAMPClient;