module ControlHub

  # Debugging tool
  class Debug

    def initialize(out, options = {})
      @out = out
      @start = Time.now
      populate_level(options)
    end

    def time
      Time.now - @start
    end

    def puts(message)
      @out.puts(format(message).colorize(:blue)) if @info
    end
    alias_method :info, :puts

    def exception(exception)
      if @exception
        message = format(exception.message)
        @out.puts(message.colorize(:red))
      end
    end
    alias_method :error, :exception

    private

    def populate_level(options = {})
      if !options[:show].nil?
        show = [options[:show]].flatten.compact
        @exception = !(show & [:exception, :error]).empty?
        @info = !(show & [:info, :message]).empty?
      end
      @exception = true if @exception.nil?
      @info = true if @info.nil?
    end

    def format(message)
      "[#{time.seconds.round(2)} #{caller_method.upcase}] #{message}"
    end

    def caller_method(depth=1)
      parse_caller(caller(depth+1).first)
    end

    private

    def parse_caller(at)
      if /^(.+?):(\d+)(?::in `(.*)')?/ =~ at
        file   = Regexp.last_match[1]
        file.scan(/.+\/(\w+)\.rb/)[0][0]  
      end
    end

  end

end

