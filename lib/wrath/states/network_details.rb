module Wrath
  class NetworkDetails < Gui

    TEXT_ENTRY_OPTIONS = { height: 5, padding: 2, width: 90 }

    protected
    def name_entry
      label t.label.player_name
      @player_name = text_area TEXT_ENTRY_OPTIONS.merge(text: settings[:player, :name])
    end

    protected
    def port_entry
      label t.label.port
      @port = text_area TEXT_ENTRY_OPTIONS.merge(text: settings[:network, :port].to_s)
    end
  end
end