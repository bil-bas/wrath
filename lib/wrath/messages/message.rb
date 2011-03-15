 # Abstract class, parent of all packets.
module Wrath
class Message
  include Log

  public
  def object_by_id(id)
    $window.current_game_state.object_by_id(id)
  end
end
end

