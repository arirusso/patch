Patch = function() {}

// Initialize a websocket
Patch.Websocket = function(network, options) {
  options = options || {};
  this.debug = options.debug || false;
  this.webSocket;
  this.network = network;
  this.onClose = options.onClose;
  this.initialize();
}

// Convert the raw websocket event to an array of message objects
Patch.Websocket.eventToControllerMessages = function(event) {
  var messages = []
  var rawMessages = JSON.parse(event.data);
  for (var i in rawMessages) {
    var rawMessage = rawMessages[i];
    var message = Patch.Websocket.processMessage(rawMessage);
    messages.push(message);
  }
  return messages;
}

// Convert a raw message's properties into more meaningful types, etc
Patch.Websocket.processMessage = function(message) {
  var timestamp = Number(message.timestamp);
  message.time = new Date(timestamp);
  message.index = Number(message.index);
  message.value = parseFloat(message.value);
  return message;
}

// initialize the socket
Patch.Websocket.prototype.initialize = function() {
  var address = "ws://" + this.network.host + ":" + this.network.port + "/echo";
  if ("WebSocket" in window)
  {
    this.webSocket = new WebSocket(address);
    this.webSocket.onopen = function() {
      console.log("patch ready")  
    };
    var controller = this;
    this.webSocket.onclose = function() {  
      console.log("patch closed"); 
      if (controller.onClose !== undefined && controller.onClose !== null) {
        controller.onClose();
      }
    };
  } else {
    console.log("websocket not supoorted");
  }
}

// Disable the controller
Patch.Websocket.prototype.disable = function() {
  this.webSocket.onmessage = function(event) {};
  return false;
}

// Handle a single event
Patch.Websocket.prototype.handleEvent = function(event, callback) {
  var messages = Patch.Websocket.eventToControllerMessages(event);
  if (this.debug) {
    console.log("messages received: ");
    console.log(messages);
  }
  callback(messages);
  return messages;
}

// Initialize controller events
Patch.Websocket.prototype.setInputCallback = function(callback) {
  var controller = this;
  this.webSocket.onmessage = function(event) { 
    controller.handleEvent(event, callback); 
  };
  return true;
}
