module ControlHub

  module Input

    # Receive MIDI messages and do something with them
    module MIDI

      def self.new(*a)
        Listener.new(*a)
      end

      class Listener

        attr_reader :controls, :input, :listener

        def initialize(input_info, controls, options = {})
          select_input(input_info)
          unless @input.nil?
            @control = controls
            @listener = MIDIEye::Listener.new(@input)
          end
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
          index = (message.index - 1)
          hash = { :index => {}, :value => {} }
          @control.each do |namespace, schema| 
            mapping = schema.find { |mapping| mapping[:index] == index }
            hash[:value][namespace] = get_value(mapping[:midi], message)
            hash[:index][namespace] = mapping[:index]
          end
          hash
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

        def select_input(input_info)
          @input = if input_info == "choose"
                     UniMIDI::Input.gets
                   elsif !input_info[:name].nil?
                     UniMIDI::Input.find_by_name(input_info[:name])
                   end
        end

        def configure_listener(&block)
          @listener.listen_for(:class => [MIDIMessage::ControlChange]) do |event|
            handle_event_received(event, &block)
          end
        end

      end

      module Config

        def midi_input_class
          Listener
        end

        def midi_inputs
          nodes(:input, :type => :midi)
        end

        def midi_input?
          !midi_inputs.nil? && !midi_inputs.empty?
        end

        def midi_controls
          @midi_controls ||= controls(:midi)
        end

        def midi_control?
          control? && !midi_controls.empty?
        end

        def midi?
          midi_input? && midi_control?
        end

      end
    end
  end
end
