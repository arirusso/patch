module Patch 

  # A generic controller message
  class Message

    attr_accessor :index, :patch_name, :value
    attr_reader :time

    # @param [Hash] properties
    def initialize(properties = nil)
      populate_from_properties(properties) unless properties.nil?
      @time ||= Time.now
    end

    # Convert the message to a hash
    # @return [Hash]
    def to_h
      properties = {
        :index => @index, 
        :patch_name => @patch_name, 
        :timestamp => timestamp, #js format
        :value => @value
      }
      properties.merge!(@other_properties) unless @other_properties.nil?
      properties
    end

    # Convert the message to a JSON string
    # @return [String]
    def to_json(*args)
      to_h.to_json(*args)
    end

    # Get the message time as a JS timestamp
    # @return [Fixnum]
    def timestamp
      @time.to_i * 1000
    end

    private

    # Populate this message from a hash of properties
    # @param [Hash] properties
    # @return [Hash]
    def populate_from_properties(properties)
      properties = properties.dup
      @index = properties.delete(:index)
      @patch_name = properties.delete(:patch_name)
      @value = properties.delete(:value)
      if !(timestamp = properties.delete(:timestamp)).nil?
        @time = timestamp_to_time(timestamp)
      end
      @other_properties = properties
    end

    # Convert a raw timestamp to a Ruby time
    # @param [String, Numeric] timestamp
    # @return [Time]
    def timestamp_to_time(timestamp)
      js_time = timestamp.to_i / 1000
      Time.at(js_time)
    end

  end

end
