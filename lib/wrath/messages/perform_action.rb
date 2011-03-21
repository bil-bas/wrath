module Wrath
class Message
  # Perform the action, send from the host to the client.
  class PerformAction < RequestAction
    def activate(actor, target)
      actor.perform_action(target)
    end
  end
end
end