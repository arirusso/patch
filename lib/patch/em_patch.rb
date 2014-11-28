# These patches are useful for using both an OSC and Websocket server concurrently
#
module OSC
  class EMServer

    def run
      open
    end

    def open
      EM::open_datagram_socket("0.0.0.0", @port, Connection)
    end

    def remove_method(address_pattern)
      matcher = AddressPattern.new( address_pattern )

      @tuples.delete_if { |pattern, proc| pattern == matcher }
    end

  end
end

module EventMachine
  module WebSocket
    def self.start(options, &blk)
      #EM.epoll
      #EM.run {
        trap("TERM") { stop }
        trap("INT")  { stop }

        run(options, &blk)
      #}
    end

    def self.run(options)
      host, port = options.values_at(:host, :port)
      EM.start_server(host, port, Connection, options) do |c|
        begin
          yield c
        rescue Exception => exception
          Thread.main.raise(exception)
        end
      end
    end
  end
end
