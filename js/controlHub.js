ControlHub = function(network, onClose) {
  this.debug = false;
  this.webSocket;
  this.network = network;
  this.onClose = onClose;
}

// Convert the raw websocket JSON message
ControlHub.eventToControllerMessage = function(evt) {
  var msg = JSON.parse(evt.data);
  // format values
  for (var i in msg) {
    if (i === 'timestamp') {
      var timestamp = Number(msg.timestamp);
      msg.time = new Date(timestamp);
    } else {
      msg[i].index = Number(msg[i].index);
      msg[i].value = parseFloat(msg[i].value);
    }
  }
  return msg;
}

// initialize the socket
ControlHub.prototype.initialize = function() {
  var address = "ws://" + this.network.host + ":" + this.network.port + "/echo";
  if ("WebSocket" in window)
  {
    this.webSocket = new WebSocket(address);
    this.webSocket.onopen = function() {
      console.log("control hub ready")  
    };
    var controller = this;
    this.webSocket.onclose = function() {  
      console.log("control hub closed"); 
      controller.onClose();
    };
  } else {
    console.log("websocket not supoorted");
  }
}

// Disable the controller
ControlHub.prototype.disable = function() {
  this.webSocket.onmessage = function(event) {};
}

// Handle a single event
ControlHub.prototype.handleEvent = function(event, callback) {
  var messages = ControlHub.eventToControllerMessage(event);
  for (var message in messages) {
    message.time = messages.time;
    if (this.debug) {
      console.log("message received");
      console.log(message);
    }
    callback(message);
  }
  return messages;
}

// Initialize controller events
ControlHub.prototype.initializeEventHandler = function(callback) {
  var controller = this;
  this.webSocket.onmessage = function(event) { 
    controller.handleEvent(event, callback); 
  };
}
