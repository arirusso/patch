module Patch 

  module IO

    module MIDI

      def self.new(spec, options = {})
        directions = {
          :input => Input, 
          :output => Output
        }
        klass = case spec[:direction].to_sym
          when :input then Input
          when :output then Output
        end
        klass.new(spec, :action => options[:action], :debug => options[:debug])
      end

      class Input

        attr_reader :id, :input, :listener
        attr_writer :action

        def initialize(spec, options = {})
          @action = options[:action]
          @debug = options[:debug]
          @id = spec[:id]
          @input = get_input(spec)
          @listener = MIDIEye::Listener.new(@input) unless @input.nil?
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
          @action.each do |namespace, schema| 
            mapping = schema.at(index)
            message = Patch::Message.new
            message.index = index
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

        def get_input(spec)
          case spec[:name]
          when "choose" then UniMIDI::Input.gets
          when nil then nil
          else UniMIDI::Input.find_by_name(spec[:name])
          end
        end

        def configure_listener(&block)
          @listener.listen_for(:class => [MIDIMessage::ControlChange]) do |event|
            handle_event_received(event, &block)
          end
        end

      end

      class Output

        def initialize(output_info, options = {})
          @debug = options[:debug]
          @id = output_info[:id]
          @output = get_output(output_info)
        end

        # Convert message objects to MIDI and send
        # @param [Array<Patch::Message>, Patch::Message] messages Message(s) to send via MIDI
        # @return [Boolean]
        def out(messages)
          #todo
        end

        private

        def get_output(output_info)
          case output_info[:name]
          when "choose" then UniMIDI::Output.gets
          when nil then nil
          else UniMIDI::Output.find_by_name(output_info[:name])
          end
        end

      end

    end

  end
end
