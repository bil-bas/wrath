module Wrath
  class NetworkDetails < Gui
    protected
    def name_entry
      label t.label.player_name
      @player_name = text_area text: settings[:player, :name], max_height: 30, width: $window.width / 2
    end

    protected
    def port_entry
      label t.label.port
      @port = text_area text: settings[:network, :port].to_s, max_height: 30, width: $window.width / 2
    end
  end
end