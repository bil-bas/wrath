require 'base64'
require 'json'
require 'time'

  # Abstract class, parent of all packets.
  class Message
    JSON_CLASS = 'json_class'

    # Class => {name => default, name => default, ...]
    @@value_defaults = Hash.new { |hash, key| hash[key] = {} }

    # Values are stored internally keyed by strings, but for the user they are symbols.
    # Boolean values are read via "value?()".
    protected
    def self.value(symbol, default)
      @@value_defaults[self][symbol] = default
      class_eval(<<-EOS, __FILE__, __LINE__)
        def #{symbol}#{[true, false].include?(default) ? '?' : ''}
          default = @@value_defaults[self.class][:#{symbol}]
          value = @values['#{symbol}']
          # Symbol values are converted back into symbols when read.
          value = value.to_sym if default.is_a?(Symbol) and value  
          value || default
        end
      EOS
    end

    protected
    def initialize(values = {})
      @values = Hash.new
      @@value_defaults[self.class].each_pair do |symbol, default|
        key = if values.has_key? JSON_CLASS
          symbol.to_s # Being re-constructed from a stream.
        else         
          symbol # Being initially created.
        end
        @values[symbol.to_s] = values[key] unless values[key] == default or values[key].nil?
      end
    end

    public
    def to_json(*args)
      @values.merge(JSON_CLASS => self.class.name).to_json(*args)
    end

    protected
    def self.json_create(message)
      new(message)
    end

    # Read the next message from a stream.
    #
    # === Parameters
    # +io+:: Stream from which to read a message.
    #
    # Returns message read [Message]
    public
    def self.read(io)
      json = io.gets
      raise IOError.new("Failed to read message") unless json

      message = JSON.parse(json)

      message
    end

    # Write the message onto a stream.
    #
    # === Parameters
    # +io+:: Stream on which to write self.
    #
    # Returns the number of bytes written (not including the size header).
    public
    def write(io)
      json = to_json
      io.puts(json)

      json.size
    end

    public
    def ==(other)
      (other.class == self.class) and (other.instance_eval { @values } == @values)
    end

    public
    def find_object_by_id(id)
      $window.current_game_state.objects.find {|o| o.id == id }
    end


    # Sent by client in response to making a connection.
    class Ready < Message
      def process
        puts "Client is ready"
        $window.push_game_state Play.new(:server)
      end
    end

    # Messages sent by server to the client
    class Status < Message
      value :id, nil
      value :time, nil
      value :position, nil
      value :velocity, nil

      def process
        find_object_by_id(id).update_status(self)
      end
    end

    class Destroy < Message
      value :id, nil

      def process
        find_object_by_id(id).destroy
      end
    end

    class PickUp < Message
      value :actor, nil
      value :object, nil

      def process
        find_object_by_id(actor).pick_up(find_object_by_id(object))
      end
    end

    class Drop < Message
      value :actor, nil

      def process
        find_object_by_id(actor).drop
      end
    end

    class Create < Message
      value :object_class, "Object"
      value :options, {}

      def initialize(*args)
        super(*args)

        # Convert options into symbolic hash.
        options = @values["options"]
        symbolised_options = Hash.new
        options.each_pair do |key, value|
          symbolised_options[key.to_sym] = value
        end
        @values["options"] = symbolised_options
      end

      def process
        object = Kernel::const_get(object_class.to_sym).create(options)
        $window.current_game_state.objects.push object
        puts "Created a #{object_class}"
      end
    end
  end

