# Patch
# Controller message patching
#
# Ari Russo
# (c)2014-2015
# Licensed under Apache 2.0
#

# Libs
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

# Modules
require "patch/config"
require "patch/io"
require "patch/node"
require "patch/thread"

# Classes
require "patch/action"
require "patch/hub"
require "patch/log"
require "patch/message"
require "patch/patch"
require "patch/report"

# Patches
require "patch/em_patch"

module Patch

  VERSION = "0.4.7"

end
