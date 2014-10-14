module Patch 

  # A generic controller message
  class Message

    attr_accessor :index, :patch_name, :value
    attr_reader :time

    # @param [Hash] options
    # @option options [Boolean] :debug
    # @option options [Hash] :raw_message
    def initialize(options = {})
      @debug = options[:debug]
      populate_from_hash(options[:raw_message]) unless options[:raw_message].nil?
      @time ||= Time.now
    end

    # Convert the message to a hash
    # @return [Hash]
    def to_h(*args)
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
      to_h(*args).to_json
    end

    # Get the message time as a JS timestamp
    # @return [Fixnum]
    def timestamp
      @time.to_i * 1000
    end

    private

    # Populate this message from a hash of properties
    # @param [Hash] hash
    # @return [Hash]
    def populate_from_hash(hash)
      hash = hash.dup
      @index = hash.delete(:index)
      @patch_name = hash.delete(:patch_name)
      @value = hash.delete(:value)
      if !(timestamp = hash.delete(:timestamp)).nil?
        @time = timestamp_to_time(timestamp)
      end
      @other_properties = hash
      hash
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
