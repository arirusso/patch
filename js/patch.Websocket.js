Patch = function() {}

// Initialize a websocket
Patch.Websocket = function(network, options) {
  options = options || {};
  this.debug = options.debug || false;
  this.logger = options.logger || console;
  this.onClose = options.onClose;
  this.webSocket;
  this._initialize(network);
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
  message = this._prepareMessageForSend(message);
  if (this.debug) {
    this.logger.log("Patch: Sending message");
    this.logger.log(message);
  }
  var json = JSON.stringify(message);
  this.webSocket.send(json);
  return true;
}

// Private methods

Patch.Websocket._prepareMessageForSend = function(message) {
  message.time = new Date();
  message.timestamp = message.time.getTime();
  return message;
}

// Convert the raw websocket event to an array of message objects
Patch.Websocket._eventToControllerMessages = function(event, logger) {
  var messages = null;
  var rawMessages = Patch.Websocket._parseEvent(event, logger);
  if (rawMessages !== undefined && rawMessages !== null) {
    messages = [];
    for (var i = 0; i < rawMessages.length; i++) {
      var rawMessage = rawMessages[i];
      var message = Patch.Websocket._processMessage(rawMessage);
      messages.push(message);
    }
  }
  return messages;
}

Patch.Websocket._parseEvent = function(event, logger) {
  var rawMessages;
  try {
    rawMessages = JSON.parse(event.data);
  } catch (err) {
    if (err.name == "SyntaxError") {
      Patch.Websocket._handleNonPatchMessage(logger);
    } else {
      throw(err);
    }
  }
  return rawMessages;
}

Patch.Websocket._handleNonPatchMessage = function(logger) {
  if (logger !== undefined && logger !== null) {
    logger.log("Patch: Unformated data received");
    logger.log(event.data);
  }
  return null;
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
Patch.Websocket.prototype._getAddress = function(network) {
  return "ws://" + network.host + ":" + network.port + "/echo";
}

Patch.Websocket.prototype._handleOpen = function() {
  this.logger.log("Patch: Ready");
}

Patch.Websocket.prototype._handleClose = function() {
  this.logger.log("Patch: Closed");
  if (this.onClose !== undefined && this.onClose !== null) {
    this.onClose();
  }
}

Patch.Websocket.prototype._initializeSocket = function(network) {
  var controller = this;
  
  var address = this._getAddress(network);
  this.webSocket = new WebSocket(address);
  this.webSocket.onopen = function() {
    controller._handleOpen();
  };
  this.webSocket.onclose = function() {
    controller._handleClose();
  };
}

// Initialize the socket
Patch.Websocket.prototype._initialize = function(network) {
  this.logger.log("Patch: Initializing")

  if (this.isCompatible())
  {
    this._initializeSocket(network);
    return true;
  } else {
    this.logger.log("Patch: Websockets not supported");
    return false;
  }
}
