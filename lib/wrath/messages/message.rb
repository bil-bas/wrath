 # Abstract class, parent of all packets.
module Wrath
class Message
  include Log

  protected
  def object_by_id(id)
    @state.object_by_id(id)
  end

  public
  def process
    @state = $window.game_state_manager.game_states.find {|state| state.networked? }
    if @state and @state.accept_message?(self)
      action(@state)
    else
      log.warn { "#{self.class} not accepted by #{@state.class} state" }
    end
  end
end
end

