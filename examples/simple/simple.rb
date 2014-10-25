#!/usr/bin/env ruby
$:.unshift File.join( File.dirname( __FILE__ ), '../../lib')

require "patch"

websocket = Patch::IO::Websocket.new(1, "localhost", 9006)
midi = Patch::IO::MIDI::Input.new(2, "Apple Inc. IAC Driver")
osc = Patch::IO::OSC::Server.new(3, 8000, :echo => { :host => "192.168.1.118", :port => 9000})

map = { [midi, osc] => websocket }

action = { 
  :name => "Zoom",
  :key => "zoom",
  :default => {
    :scale => 0.1..5.0
  },
  :midi => {
    :channel => 0,
    :index => 1
  }, 
  :osc => {
    :address=>"/1/rotaryA", 
    :scale => 0..1.0
  }
}

patch = Patch::Patch.new(:simple, map, action)

hub = Patch::Hub.new(:patch => patch)
Patch::Report.print(hub)
hub.listen
