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
      state = $window.current_game_state
      state.objects.push object

      # Ensure the objects are attached to the correct player.
      # TODO: I'd like to rely on this being less of a kludge.
      case object.id
        when 0
          state.players[0].avatar = object
        when 1
          state.players[1].avatar = object
      end

      log.debug { "Created a #{@object_class}" }
    end
  end
end
end