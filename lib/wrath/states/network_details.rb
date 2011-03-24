module Wrath
  class NetworkDetails < Gui
    def initialize
      super

      on_input(:escape) { pop_game_state }
    end

    protected
    def name_entry
      label "Player name"
      @player_name = text_area text: settings[:player, :name], max_height: 30, width: $window.width / 2
    end

    protected
    def port_entry
      label "Host port"
      @port = text_area text: settings[:network, :port].to_s, max_height: 30, width: $window.width / 2
    end
  end
end