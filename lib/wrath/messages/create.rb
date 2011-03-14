module Wrath
class Message
  class Create < Message
    protected
    def initialize(object_class, options = {})
      @object_class, @options = object_class, options
    end

    public
    def process
      object = @object_class.create(@options)
      $window.current_game_state.objects.push object
      log.debug { "Created a #{@object_class}" }
    end
  end
end
end