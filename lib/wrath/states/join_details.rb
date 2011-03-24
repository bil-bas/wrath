module Wrath
  class JoinDetails < Gui
    def initialize
      super

      on_input(:escape) { pop_game_state }

      pack :vertical, spacing: 32 do
        pack :horizontal, spacing: 16 do
          label "Host address"
          @address = text_area text: settings[:network, :address], max_height: 30, width: $window.width / 2
        end

        pack :horizontal, spacing: 16 do
          label "Host port"
          @port = text_area text: settings[:network, :port].to_s, max_height: 30, width: $window.width / 2
        end

        button("Connect") { push_game_state Client.new(address: @address.text, port: @port.text.to_i) }
      end
     end
  end
end