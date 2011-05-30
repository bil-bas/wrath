module Wrath
class Message
  # Create an object and ensure it is registered.
  class Create < Message
    public
    def initialize(object_class, options = {})
      @object_class, @options = object_class, options
    end

    protected
    def action(state)
      object = @object_class.create(@options)

      # Ensure the objects are attached to the correct player.
      # TODO: I'd like to rely on this being less of a kludge.
      case object.id
        when 1
          state.players[0].avatar = object
        when 2
          state.players[1].avatar = object
      end
    end
  end
end
end