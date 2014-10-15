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

require "em-websocket"
require "midi-eye"
require "osc-ruby"
require "osc-ruby/em_server"
require "rainbow"
require "scale"

# modules
require "patch/io"
require "patch/node"
require "patch/spec"

# classes
require "patch/action"
require "patch/debug"
require "patch/hub"
require "patch/message"
require "patch/patch"
require "patch/report"

# patches
require "patch/em_patch"

module Patch

  VERSION = "0.2"

end
