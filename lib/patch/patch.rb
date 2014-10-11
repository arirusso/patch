module OSC
  class EMServer

    def run
      open
    end

    def open
      EM::open_datagram_socket("0.0.0.0", @port, Connection)
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
