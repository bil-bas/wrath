class Message
  class Create < Message
    value :object_class, nil
    value :options, {}

    def initialize(options = {})
      if options[:object_class].is_a? Class
        options[:object_class] = options[:object_class].name.to_sym
      end

      super(options)
    end

    def process
      object = Kernel::const_get(object_class.to_sym).create(options)
      $window.current_game_state.objects.push object
      puts "Created a #{object_class}"
    end
  end
end