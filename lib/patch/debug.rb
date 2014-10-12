module Patch

  # Debugging util
  class Debug

    # @param [IO] out
    # @param [Hash] options
    # @option options [Array<Symbol>] :show
    def initialize(out, options = {})
      @out = out
      @start = Time.now
      populate_level(options)
    end

    # The current time since startup
    # @return [Time]
    def time
      Time.now - @start
    end

    # Output an info message
    # @param [String] message
    # @return [String]
    def puts(message)
      message_for_output = Rainbow(format(message)).blue
      @out.puts(message_for_output) if @info
      message
    end
    alias_method :info, :puts

    # Output an exception
    # @param [String] exception
    # @return [String]
    def exception(exception)
      if @exception
        message = format(exception.message)
        message_for_output = Rainbow(message).red
        @out.puts(message_for_output)
      end
      exception
    end
    alias_method :error, :exception

    private

    # Populate the level setting
    # @param [Hash] options
    # @return [Debug]
    def populate_level(options = {})
      if !options[:show].nil?
        show = [options[:show]].flatten.compact
        @exception = !(show & [:exception, :error]).empty?
        @info = !(show & [:info, :message]).empty?
      end
      @exception = true if @exception.nil?
      @info = true if @info.nil?
      self
    end

    # Format a message for output
    # @param [String] message
    # @return [String]
    def format(message)
      "[#{time.seconds.round(2)} #{caller_method.upcase}] #{message}"
    end

    # Get the caller method where a message originated
    # @param [Fixnum] depth
    # @return [String]
    def caller_method(depth=1)
      method = caller(depth+1).first
      parse_caller(method)
    end

    # Parse the caller name
    # @param [String] at
    # @return [String]
    def parse_caller(at)
      if /^(.+?):(\d+)(?::in `(.*)')?/ =~ at
        file   = Regexp.last_match[1]
        file.scan(/.+\/(\w+)\.rb/)[0][0]  
      end
    end

  end

end

