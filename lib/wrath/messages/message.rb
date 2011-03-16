 # Abstract class, parent of all packets.
module Wrath
class Message
  include Log

  protected
  def object_by_id(id)
    $window.current_game_state.object_by_id(id)
  end

  public
  def process
    state = $window.current_game_state
    if state.accept_message?(self)
      action(state)
    else
      log.warn { "#{self.class} not accepted by #{state.class} state" }
    end
  end
end
end

