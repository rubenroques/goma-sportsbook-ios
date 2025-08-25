/**
 * WAMP Protocol Message Formatter
 * Handles creation and parsing of WAMP protocol messages
 */

// WAMP Message Types
const MessageTypes = {
  HELLO: 1,
  WELCOME: 2,
  ABORT: 3,
  CHALLENGE: 4,
  AUTHENTICATE: 5,
  GOODBYE: 6,
  ERROR: 8,
  PUBLISH: 16,
  PUBLISHED: 17,
  SUBSCRIBE: 32,
  SUBSCRIBED: 33,
  UNSUBSCRIBE: 34,
  UNSUBSCRIBED: 35,
  EVENT: 36,
  CALL: 48,
  CANCEL: 49,
  RESULT: 50,
  REGISTER: 64,
  REGISTERED: 65,
  UNREGISTER: 66,
  UNREGISTERED: 67,
  INVOCATION: 68,
  INTERRUPT: 69,
  YIELD: 70
};

class MessageFormatter {
  constructor(config) {
    this.config = config;
    this.requestId = 0;
  }

  /**
   * Generate a unique request ID
   */
  getNextRequestId() {
    return ++this.requestId;
  }

  /**
   * Create HELLO message for initial handshake
   */
  createHello() {
    return [
      MessageTypes.HELLO,
      this.config.realm,
      {
        roles: this.config.roles
      }
    ];
  }

  /**
   * Create CALL message for RPC
   */
  createCall(procedure, args = [], kwargs = {}, options = {}) {
    return [
      MessageTypes.CALL,
      this.getNextRequestId(),
      options,
      procedure,
      args,
      kwargs
    ];
  }

  /**
   * Create SUBSCRIBE message
   */
  createSubscribe(topic, options = {}) {
    return [
      MessageTypes.SUBSCRIBE,
      this.getNextRequestId(),
      options,
      topic
    ];
  }

  /**
   * Create UNSUBSCRIBE message
   */
  createUnsubscribe(subscriptionId) {
    return [
      MessageTypes.UNSUBSCRIBE,
      this.getNextRequestId(),
      subscriptionId
    ];
  }

  /**
   * Create GOODBYE message
   */
  createGoodbye(reason = 'wamp.close.normal') {
    return [
      MessageTypes.GOODBYE,
      {},
      reason
    ];
  }

  /**
   * Parse incoming message and identify type
   */
  parseMessage(message) {
    if (!Array.isArray(message) || message.length === 0) {
      throw new Error('Invalid WAMP message format');
    }

    const messageType = message[0];
    
    switch (messageType) {
      case MessageTypes.WELCOME:
        return {
          type: 'WELCOME',
          sessionId: message[1],
          details: message[2]
        };
        
      case MessageTypes.ABORT:
        return {
          type: 'ABORT',
          details: message[1],
          reason: message[2]
        };
        
      case MessageTypes.RESULT:
        return {
          type: 'RESULT',
          requestId: message[1],
          details: message[2],
          args: message[3],
          kwargs: message[4]
        };
        
      case MessageTypes.ERROR:
        return {
          type: 'ERROR',
          requestType: message[1],
          requestId: message[2],
          details: message[3],
          error: message[4],
          args: message[5],
          kwargs: message[6]
        };
        
      case MessageTypes.SUBSCRIBED:
        return {
          type: 'SUBSCRIBED',
          requestId: message[1],
          subscriptionId: message[2]
        };
        
      case MessageTypes.UNSUBSCRIBED:
        return {
          type: 'UNSUBSCRIBED',
          requestId: message[1]
        };
        
      case MessageTypes.EVENT:
        return {
          type: 'EVENT',
          subscriptionId: message[1],
          publicationId: message[2],
          details: message[3],
          args: message[4],
          kwargs: message[5]
        };
        
      case MessageTypes.GOODBYE:
        return {
          type: 'GOODBYE',
          details: message[1],
          reason: message[2]
        };
        
      default:
        return {
          type: 'UNKNOWN',
          messageType,
          data: message
        };
    }
  }

  /**
   * Format message for logging
   */
  formatForLog(message, direction = 'sent') {
    const formatted = JSON.stringify(message);
    return `${direction} ${formatted}`;
  }
}

module.exports = { MessageFormatter, MessageTypes };