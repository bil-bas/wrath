class Message
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