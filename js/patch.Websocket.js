Patch = function() {}

// Initialize a websocket
Patch.Websocket = function(network, options) {
  options = options || {};
  this.debug = options.debug || false;
  this.logger = options.logger || console;
  this.network = network;
  this.onClose = options.onClose;
  this.webSocket;
  this._initialize();
}

// Disable the controller
Patch.Websocket.prototype.disable = function() {
  this.webSocket.onmessage = function(event) {};
  return false;
}

// Initialize controller events
Patch.Websocket.prototype.onInput = function(callback) {
  var controller = this;
  this.webSocket.onmessage = function(event) {
    controller._handleEvent(event, callback);
  };
  return true;
}
Patch.Websocket.prototype.setInputCallback = function(callback) {
  return this.onInput(callback);
}

// Is the client able to use websockets?
Patch.Websocket.prototype.isCompatible = function() {
  return ("WebSocket" in window);
}

Patch.Websocket.prototype.echoMessage = function(message) {
  return this.sendMessage(message);
}

Patch.Websocket.prototype.sendMessage = function(message) {
  message.time = Date.now();
  if (this.debug) {
    this.logger.log("Patch: Sending message");
    this.logger.log(message);
  }
  var json = JSON.stringify(message);

  this.webSocket.send(json);
  return true;
}

// Private methods

// Convert the raw websocket event to an array of message objects
Patch.Websocket._eventToControllerMessages = function(event, logger) {
  var messages = [];
  try {
    var rawMessages = JSON.parse(event.data);
  } catch (err) {
    if (err.name == "SyntaxError") {
      if (logger !== undefined && logger !== null) {
        logger.log("Patch: Data received");
        logger.log(event.data);
      }
      return null;
    } else {
      throw(err);
    }
  }
  for (var i = 0; i < rawMessages.length; i++) {
    var rawMessage = rawMessages[i];
    var message = Patch.Websocket._processMessage(rawMessage);
    messages.push(message);
  }
  return messages;
}

// Convert a raw message's properties into more meaningful types, etc
Patch.Websocket._processMessage = function(message) {
  var timestamp = Number(message.timestamp);
  message.time = new Date(timestamp);
  message.index = Number(message.index);
  message.value = parseFloat(message.value);
  return message;
}

// Handle a single event
Patch.Websocket.prototype._handleEvent = function(event, callback) {
  var messageLogger = (this.debug) ? this.logger : null;
  var messages = Patch.Websocket._eventToControllerMessages(event, messageLogger);
  if (messages !== undefined && messages !== null) {
    if (this.debug) {
      this.logger.log("Patch: Messages received");
      this.logger.log(messages);
    }
    callback(messages);
  }
  return messages;
}

// The websocket address
Patch.Websocket.prototype._getAddress = function() {
  return "ws://" + this.network.host + ":" + this.network.port + "/echo";
}

// Initialize the socket
Patch.Websocket.prototype._initialize = function() {
  var logger = this.logger;

  logger.log("Patch: Initializing")
  var address = this._getAddress();
  if (this.isCompatible())
  {
    this.webSocket = new WebSocket(address);
    this.webSocket.onopen = function() {
      logger.log("Patch: Ready");
    };
    var controller = this;
    this.webSocket.onclose = function() {
      logger.log("Patch: Closed");
      if (controller.onClose !== undefined && controller.onClose !== null) {
        controller.onClose();
      }
    };
  } else {
    logger.log("Patch: Websockets not supported");
    return false;
  }
  return true;
}
