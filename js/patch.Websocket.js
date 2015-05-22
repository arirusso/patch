// Patch browser component
Patch = function() {}

// Console/Browser logging class
Patch.Logger = function(dictionary, logger, shouldDebug) {
  this.shouldDebug = shouldDebug || false;
  this.dictionary = dictionary;
  this.logger = logger || console;
}

// Log an error
Patch.Logger.prototype.error = function(message) {
  this.logger.error(message);
}

// Log a debug message
Patch.Logger.prototype.debug = function(message) {
  if (this.shouldDebug) {
    this.info(message);
  }
}

// Log an object for debug
Patch.Logger.prototype.debugObject = function(message) {
  if (this.shouldDebug) {
    this.object(message);
  }
}

// Log a message
Patch.Logger.prototype.info = function(message) {
  this.logger.log(this.dictionary.prefix + message);
}

// Log an object
Patch.Logger.prototype.object = function(object) {
  this.logger.log(object);
}

// A patch message
Patch.Message = function() {}

// Ensure that a patch message has necessary fields for sending
Patch.Message.prepareForSend = function(message) {
  message.time = new Date();
  message.timestamp = message.time.getTime();
  return message;
}

// Convert a raw message's properties into more meaningful types, etc
Patch.Message.initialize = function(message) {
  var timestamp = Number(message.timestamp);
  message.time = new Date(timestamp);
  message.index = Number(message.index);
  message.value = parseFloat(message.value);
  return message;
}

// Use Patch over websocket
Patch.Websocket = function(network, options) {
  options = options || {};
  this.logger = new Patch.Logger(Patch.Websocket.LOGMESSAGE, options.logger, options.debug);
  this.onClose = options.onClose;
  this.webSocket;
  this._initialize(network);
}

// Logging messages
Patch.Websocket.LOGMESSAGE = {
  closed: "Closed",
  initialize: "Initializing",
  notSupported: "Websockets not supported",
  ready: "Ready",
  receivedMessages: "Messages received",
  receivedUnformatted: "Unformated data received",
  prefix: "Patch: ",
  sending: "Sending message"
}

// Convert the raw websocket event to an array of message objects
Patch.Websocket.eventToControllerMessages = function(event, logger) {
  var messages;
  var rawMessages = Patch.Websocket.parseEvent(event, logger);
  if (rawMessages !== undefined && rawMessages !== null) {
    messages = [];
    for (var i = 0; i < rawMessages.length; i++) {
      var rawMessage = rawMessages[i];
      var message = Patch.Message.initialize(rawMessage);
      messages.push(message);
    }
  }
  return messages;
}

// The websocket address
Patch.Websocket.getAddress = function(network) {
  return "ws://" + network.host + ":" + network.port + "/echo";
}

// Is the client able to use websockets?
Patch.Websocket.isClientCompatible = function() {
  return ("WebSocket" in window);
}

// Convert a received event to patch messages
Patch.Websocket.parseEvent = function(event, logger) {
  var rawMessages;
  try {
    rawMessages = JSON.parse(event.data);
  } catch (err) {
    if (err.name == "SyntaxError") {
      Patch.Websocket.handleNonPatchMessage(logger);
    } else {
      throw(err);
    }
  }
  return rawMessages;
}

// Handle receiving data other than a patch message
Patch.Websocket.handleNonPatchMessage = function(logger) {
  logger.debug(Patch.Websocket.LOGMESSAGE.receivedUnformatted);
  logger.debugObject(event.data);
  return null;
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
Patch.Websocket.prototype.setInputCallback = Patch.Websocket.prototype.onInput;

// Send a patch message over the websocket
Patch.Websocket.prototype.sendMessage = function(message) {
  message = Patch.Message.prepareForSend(message);
  this.logger.debug(Patch.Websocket.LOGMESSAGE.sending);
  this.logger.debugObject(message);
  var json = JSON.stringify(message);
  this.webSocket.send(json);
  return true;
}
Patch.Websocket.prototype.echoMessage = Patch.Websocket.prototype.sendMessage;

// Handle a single received event
Patch.Websocket.prototype._handleEvent = function(event, callback) {
  var messages = Patch.Websocket.eventToControllerMessages(event, this.logger);
  if (messages !== undefined && messages !== null) {
    this.logger.debug(Patch.Websocket.LOGMESSAGE.receivedMessages);
    this.logger.debugObject(messages);
    callback(messages);
  }
  return messages;
}

// What to do when the websocket registers as open
Patch.Websocket.prototype._handleOpen = function() {
  this.logger.info(Patch.Websocket.LOGMESSAGE.ready);
}

// What to do when the websocket registers as closed
Patch.Websocket.prototype._handleClose = function() {
  this.logger.info(Patch.Websocket.LOGMESSAGE.closed);
  if (this.onClose !== undefined && this.onClose !== null) {
    this.onClose();
  }
}

// Initialize the underlying websocket
Patch.Websocket.prototype._initializeSocket = function(network) {
  var controller = this;

  var address = Patch.Websocket.getAddress(network);
  this.webSocket = new WebSocket(address);
  this.webSocket.onopen = function() {
    controller._handleOpen();
  };
  this.webSocket.onclose = function() {
    controller._handleClose();
  };
}

// Initialize the socket if possible
Patch.Websocket.prototype._initialize = function(network) {
  this.logger.info(Patch.Websocket.LOGMESSAGE.initialize);

  if (Patch.Websocket.isClientCompatible())
  {
    this._initializeSocket(network);
    return true;
  } else {
    this.logger.error(Patch.Websocket.LOGMESSAGE.notSupported);
    return false;
  }
}
