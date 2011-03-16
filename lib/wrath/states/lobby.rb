module Wrath
  class Lobby < GameState
    attr_reader :network

    public
    def accept_message?(message); [Message::NewGame].find {|m| message.is_a? m }; end

    public
    def initialize(network, opponent_name)
      super()

      @network, @opponent_name = network, opponent_name

      on_input(:escape) { game_state_manager.pop_until_game_state Menu }

      if @network.is_a? Server
        on_input(:space) { push_game_state Play.new(@network) }
        Text.create(text: "Lobby - press space to play")
      else
        @network.send_msg(Message::ClientReady.new(setting(:player_name)))
        Text.create(text: "Lobby - wait for host to start game")
      end

      Text.create(y: 50, text: "Playing against #{@opponent_name}")
    end

    public
    def update
      super
      @network.update
    end
  end
end