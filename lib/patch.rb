# Patch
# Controller message patching
#
# Ari Russo
# (c)2014-2015
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
require "patch/config"
require "patch/io"
require "patch/node"

# classes
require "patch/action"
require "patch/hub"
require "patch/log"
require "patch/message"
require "patch/patch"
require "patch/report"

# patches
require "patch/em_patch"

module Patch

  VERSION = "0.4.0"

end
