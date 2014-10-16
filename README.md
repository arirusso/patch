# Patch

Patch is a hub for controlling [things](http://en.wikipedia.org/wiki/Internet_of_Things). 

It enables universal translation and routing of messages via these protocols

* MIDI
* OSC
* JSON over Websocket
* HTTP (in progress)
* RPC (in progress)

## Usage

### Installation

Patch is packaged as a Ruby gem.  

It can be installed by using `gem install patch` on the command line or by adding `gem "patch"` to a project's Gemfile.

### Configuration

Running patch requires two configuration files:

##### Nodes

A node is a single source/destination of control messages.  The first configuration file describes what nodes to use.  Notice that each node is given an ID number.

```yaml
:nodes:
  - :type: websocket
    :id: 1
    :host: localhost
    :port: 9006
  - :type: midi
    :direction: input
    :id: 2
    :name: Apple Inc. IAC Driver
  - :type: osc
    :server:
      :port: 8000
    :client:
      :host: 192.168.1.136
      :port: 9000
    :id: 3
```

##### Patches

A patch describes how nodes are used exactly, and are defined in a second configuration file:

```yaml
---
:simple:
  :node_map:
    [2, 3]: 1
  :actions:
  - :name: Zoom
    :key: zoom
    :midi:
      :channel: 0
      :index: 0
      :scale: !ruby/range 0.1..5.0
    :osc:
      :address: /1/rotaryA
      :scale:
        :osc: !ruby/range 0..1
        :hub: !ruby/range 10..200
```

The top level `simple` is the name of the first patch.  A patch then consists of two parts, node map and actions.

###### Node Map

The `node_map` defines where messages should go to and from.  

In this case, when the nodes with the IDs 2 (MIDI) and 3 (OSC) receive messages, echo those messages to the node with the ID 1 (JSON over Websocket).

###### Actions

Message formats like MIDI and OSC have no implicit way to translate information between each other.  Therefore, we need to describe a list of actions to define how to do that. 

Given this particular example above:

- When a MIDI control change message is received on channel 0 with index 0, send a JSON over websocket message with the key "zoom", converting the 0 to 127 MIDI value to a float between 0 to 5.

- When an OSC message is received for address `/1/rotaryA`, send a JSON over websocket message with the key "zoom", converting the 0 to 1 OSC float value to a float between 10 and 200.

Once these configuration files are in place, you can run patch by doing `patch nodes.yml patches.yml` at the command line.

## Author

[Ari Russo](http://github.com/arirusso) <ari.russo at gmail.com>

## License

This version under Apache 2.0, See the file LICENSE
Copyright (c) 2014 [Ari Russo](http://arirusso.com) 
