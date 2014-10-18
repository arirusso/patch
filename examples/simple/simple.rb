#!/usr/bin/env ruby
$:.unshift File.join( File.dirname( __FILE__ ), '../../lib')

require "patch"

nodes = Patch::Node::Container.new
nodes << Patch::IO::Websocket.new(1, "localhost", 9006)
nodes << Patch::IO::OSC::Server.new(2, 8000, :echo => { :host => "192.168.1.118", :port => 9000})

action = { 
  :name=>"Zoom",
  :key => "zoom",
  :default => {
    :scale => 0.1..5.0
  },
  :midi=> {
    :channel=>0
  }, 
  :osc => {
    :address=>"/1/rotaryA", 
    :scale => 0..1.0
  }
}

patch = Patch::Patch.new(:simple, action, { 2 => 1 })

hub = Patch::Hub.new(:nodes => nodes, :patches => patch)
Patch::Report.print(hub)
hub.listen
