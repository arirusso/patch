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

      def listen(&block)
        if !@listener.nil?
          configure_listener(&block)
          @listener.run(:background => true)
        end
      end

      private

      def handle_event_received(event, options = {}, &block)
        output = get_output(event[:message])
        yield(output) if block_given?
        output
      end

      def get_output(message)
        index = message.index - 1
        output = Message.new
        @control.each do |namespace, schema| 
          mapping = schema.find { |mapping| mapping[:index] == index }
          output[namespace] ||= {}
          output[namespace][:value] = get_value(mapping[:midi], message)
          output[namespace][:index] = mapping[:index]
        end
        output
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
