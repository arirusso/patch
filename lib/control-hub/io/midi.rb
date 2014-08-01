module ControlHub

  module IO

    # Receive MIDI messages and do something with them
    class MIDI

      attr_reader :controls, :input, :listener

      def initialize(input_info, options = {})
        @control = options[:control]
        @input = get_input(input_info)
        @listener = MIDIEye::Listener.new(@input) unless @input.nil?
      end

      # Convert message objects to MIDI and send
      # @param [Array<ControlHub::Message>, ControlHub::Message] messages Message(s) to send via MIDI
      # @return [Boolean]
      def out(messages)
        #todo
      end

      # Start listening for MIDI input
      # @return [Boolean] Whether the listener was started
      def start
        if !@listener.nil?
          @listener.run(:background => true)
          true
        else
          false
        end
      end

      # Specify a handler callback for when messages are received
      # @return [Boolean] Whether adding the callback was successful
      def listen(&block)
        if !@listener.nil?
          configure_listener(&block)
          true
        else
          false
        end
      end

      private

      def handle_event_received(event, options = {}, &block)
        messages = get_hub_messages(event[:message])
        yield(messages) if block_given?
        messages
      end

      def get_hub_messages(raw_message)
        index = raw_message.index - 1
        messages = []
        @control.each do |namespace, schema| 
          mapping = schema.find { |mapping| mapping[:index] == index }
          message = ControlHub::Message.new
          message.index = mapping[:index]
          message.namespace = namespace
          message.value = get_value(mapping[:midi], raw_message)
          messages << message
        end
        messages
      end

      def get_value(mapping, message)
        if !mapping[:scale].nil?
          Scale.transform(message.value).from(0..127).to(mapping[:scale])
        else
          message.value
        end
      end

      def process_values(message)
        values = {}
      end

      def extract_message(event)
        message = event[:message]
        index = (message.index - 1)
        value = message.value
        {
          :index => index,
          :value => value
        }
      end

      def get_input(input_info)
        case input_info[:name]
        when "choose" then UniMIDI::Input.gets
        when nil then nil
        else UniMIDI::Input.find_by_name(input_info[:name])
        end
      end

      def configure_listener(&block)
        @listener.listen_for(:class => [MIDIMessage::ControlChange]) do |event|
          handle_event_received(event, &block)
        end
      end

    end

  end
end
