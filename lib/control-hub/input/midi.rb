module ControlHub

  module Input

    # Receive MIDI messages and do something with them
    class MIDI

      attr_reader :controls, :input, :listener

      def initialize(config, options = {})
        configure(config, options)
      end

      def listen(&block)
        if !@listener.nil?
          configure_listener(&block)
          @listener.run(:background => true)
        end
      end

      private

      def handle_event_received(event, options = {}, &block)
        message = event[:message]
        index = (message.index - 1)
        hash = { :index => {}, :value => {} }
        @control.each do |key, schema| 
          mapping = schema.find { |mapping| mapping[:index] == index }
          hash[:value][key] = if !mapping[:midi][:scale].nil?
            Scale.transform(message.value).from(0..127).to(mapping[:midi][:scale])
          else
            message.value
          end
          hash[:index][key] = mapping[:index]
        end
        yield(hash) if block_given?
        hash
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

      def configure(config, options = {})
        if !config.io[:midi][:input].nil?
          configure_input(config)
          @control = config.midi_controls
        end
      end

      def configure_input(config)
        input = config.io[:midi][:input]
        @input = if input == "choose"
          UniMIDI::Input.gets
        elsif !input[:name].nil?
          UniMIDI::Input.find_by_name(input[:name])
        end
        @listener = MIDIEye::Listener.new(@input) if !@input.nil?
      end

      def configure_listener(&block)
        @listener.listen_for(:class => [MIDIMessage::ControlChange]) do |event|
          handle_event_received(event, &block)
        end
      end

    end
  end
end
