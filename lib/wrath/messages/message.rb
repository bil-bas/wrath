  # Abstract class, parent of all packets.
  class Message
    # Values are stored internally keyed by strings, but for the user they are symbols.
    # Boolean values are read via "value?()".
    protected
    def self.value(symbol, default)
      class_eval(<<-EOS, __FILE__, __LINE__)
        def #{symbol}#{[true, false].include?(default) ? '?' : ''}
          @values[:#{symbol}]
        end
      EOS
    end

    protected
    def initialize(values = {})
      @values = values
    end

    public
    def to_yaml
      data = { type: self.class.name[/\w+$/].to_sym, values: @values }
      data.to_yaml
    end

    public
    def ==(other)
      (other.class == self.class) and (other.instance_eval { @values } == @values)
    end

    public
    def find_object_by_id(id)
      $window.current_game_state.objects.find {|o| o.id == id }
    end
  end

