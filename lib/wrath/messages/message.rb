  # Abstract class, parent of all packets.
  class Message
    public
    def find_object_by_id(id)
      $window.current_game_state.objects.find {|o| o.id == id }
    end
  end

