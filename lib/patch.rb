# Patch
# Controller message patching
#
# Ari Russo
# (c)2014
# Licensed under Apache 2.0
#

# libs
require "forwardable"
require "json"
require "socket"
require "yaml"

require "colorize"
require "em-websocket"
require "midi-eye"
require "osc-ruby"
require "osc-ruby/em_server"
require "scale"

# modules
require "patch/io"

# classes
require "patch/action"
require "patch/debug"
require "patch/hub"
require "patch/map"
require "patch/nodes"
require "patch/message"

# patches
require "patch/patch"

module Patch

  VERSION = "0.1"

  def self.new(*a)
    Hub.new(*a)
  end

  def self.listen(*a)
    @hub = new(*a)
    @hub.listen
  end

end
