# Patch

Patch is a universal hub for controlling [things](http://en.wikipedia.org/wiki/Internet_of_Things).  

These message protocols are supported

* [MIDI](http://en.wikipedia.org/wiki/MIDI)
* [OSC](http://en.wikipedia.org/wiki/Open_Sound_Control)
* JSON over [Websocket](http://en.wikipedia.org/wiki/WebSocket)
* [HTML5 Server-Sent Events](http://www.w3schools.com/html/html5_serversentevents.asp) (in progress)
* HTTP (in progress)
* [JSON RPC 2.0](http://en.wikipedia.org/wiki/JSON-RPC) (in progress)

## Usage

### Installation

Patch is packaged as a Ruby gem.  

It can be installed by using `gem install patch` on the command line or by adding `gem "patch"` to a project's Gemfile.

### Configuration

Patch can be configured in Ruby code or by using two YAML configuration files.  Since the configuration files reflect the overall structure of Patch in a straightforward way, that method is explained here.  

A tutorial on programming Patch in Ruby can be found [here].

##### nodes.yml

A node is a single source/destination of control messages.  `nodes.yml` describes plainly what nodes to use and how to configure them.  

In addition, each node is given an ID number for reference later.

```yaml
:nodes:
  - :id: 1
    :type: websocket
    :host: localhost
    :port: 9006
  - :id: 2
    :type: midi
    :direction: input
    :name: Apple Inc. IAC Driver
  - :id: 3
    :type: osc
    :server:
      :port: 8000
    :client:
      :host: 192.168.1.136
      :port: 9000
```

##### patches.yml

A patch describes how to use the nodes.  We specify this in a second configuration file `patches.yml`.

```yaml
:patches:
  :simple:
    :node_map:
      [2, 3]: 1
    :actions:
    - :name: Zoom
      :key: zoom
      :default:
        :scale: !ruby/range 10..200.0
      :midi:
        :channel: 0
        :index: 0
      :osc:
        :address: /1/rotaryA
        :scale: !ruby/range 0..1.0

```

A patch consists of two parts, node map and actions.

###### Node Map

The node map defines where messages should flow to and from.  

In this case, when the nodes with the IDs 2 (MIDI) and 3 (OSC) receive messages, those messages will then be echoed to the node with the ID 1 (JSON over Websocket).

###### Actions

The message protocols used by Patch (such as MIDI and OSC) have no implicit way to translate between each other.  Therefore, we have to provide a list of actions to describe how to do that.

Given this particular example above, these are the actions in more plain terms:

1. When a MIDI control change message is received on channel 0 with index 0, send a JSON over websocket message with the key "zoom".  The value of the MIDI message should be scaled from the standard, an int between 0 to 127, to a float between 10 and 200.

2. When an OSC message is received for address `/1/rotaryA`, send a JSON over websocket message with the key "zoom".  Scale the OSC value, a float between 0 and 1 to a float between 10 and 200.

### Run

Once these configuration files are in place, you can run patch by executing `patch nodes.yml patches.yml` at the command line.  

## Author

[Ari Russo](http://github.com/arirusso) <ari.russo at gmail.com>

## License

This version under Apache 2.0, See the file LICENSE
Copyright (c) 2014 [Ari Russo](http://arirusso.com) 