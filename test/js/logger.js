MockConsole = function() {
  this._last;
}
MockConsole.prototype.log = function(something) {
  this._last = something;
  return true;
}
MockConsole.prototype.error = MockConsole.prototype.log;
MockConsole.prototype.last = function() {
  var last = this._last;
  delete this._last;
  return last;
}

LOGMESSAGE = {
  closed: "Closed",
  prefix: "Test: ",
  open: "Open"
}

var logger;
var fakeConsole = new MockConsole();

module("Patch.Logger", {
  setup: function() {
    logger = new Patch.Logger(LOGMESSAGE, fakeConsole);
  }, teardown: function() {
    delete logger;
  }
});
test( "new", function(assert) {
  assert.ok( (logger !== undefined && logger !== null), "logger is initialized" );
});
test( "info", function(assert) {
  assert.ok(logger.info("hello"), "info method is called" );
  assert.equal(fakeConsole.last(), "Test: hello", "message is sent to underlying logger" );
});
test( "object", function(assert) {
  var obj = {something:"hello"};
  assert.ok(logger.object(obj), "object method is called" );
  assert.equal(fakeConsole.last(), obj, "object is sent to underlying logger" );
});
test( "debug", function(assert) {
  // not enabled
  logger.shouldDebug = false;
  assert.notOk(logger.debug("hello"), "debug method is called" );
  assert.equal(fakeConsole.last(), undefined, "message is not sent to underlying logger" );
  // enabled
  logger.shouldDebug = true;
  assert.ok(logger.debug("hello"), "debug method is called" );
  assert.equal(fakeConsole.last(), "Test: hello", "message is sent to underlying logger" );
});
test( "debugObject", function(assert) {
  // not enabled
  logger.shouldDebug = false;
  var obj = {something:"hello"};
  assert.notOk(logger.debugObject(obj), "debugObject method is called" );
  assert.equal(fakeConsole.last(), undefined, "object is not sent to underlying logger" );
  // enabled
  logger.shouldDebug = true;
  assert.ok(logger.debugObject(obj), "debugObject method is called" );
  assert.equal(fakeConsole.last(), obj, "object is sent to underlying logger" );
});
test( "error", function(assert) {
  assert.ok(logger.error("hello"), "error method is called" );
  assert.equal(fakeConsole.last(), "hello", "error is sent to underlying logger" );
});
