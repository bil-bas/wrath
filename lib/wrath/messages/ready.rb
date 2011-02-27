class Message
  # Sent by client in response to making a connection.
  class Ready < Message
    def process
      puts "Client is ready; telling it the game has started"

      $window.push_game_state Play.new($window.current_game_state)
    end
  end
end