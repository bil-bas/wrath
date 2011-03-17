module Wrath
  class Lobby < GameState
    attr_reader :network

    public
    def accept_message?(message); [Message::NewGame].find {|m| message.is_a? m }; end

    public
    def initialize(network, opponent_name, self_name = nil)
      super()

      self_name = setting(:player, :name) unless self_name

      @network, @self_name, @opponent_name = network, self_name, opponent_name

      on_input(:escape) { game_state_manager.pop_until_game_state Menu }

      case @network
        when Server
          Text.create(text: "Lobby - pick a level")

        when Client
          @network.send_msg(Message::ClientReady.new(setting(:player, :name)))
          Text.create(text: "Lobby - wait for host to pick a level")

        else
          Text.create(text: "Lobby")
      end

      Text.create(y: 15, text: "#{@self_name} vs #{@opponent_name}")

      # Level-picker.
      unless @network.is_a? Client
        menu_items = {}
        Play.levels.each do |level|
          menu_items[level.to_s] = ->{ push_game_state level.new(@network) }
        end

        SimpleMenu.create(spacing: 3, x: $window.retro_width / 2, y: 50, menu_items: menu_items, size: 12)
      end
    end

    public
    def update
      super
      @network.update if @network
    end
  end
end