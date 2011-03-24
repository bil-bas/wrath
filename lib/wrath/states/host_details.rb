module Wrath
  class HostDetails < Gui
    def initialize
      super

      on_input(:escape) { pop_game_state }

      pack :vertical, spacing: 32 do
        pack :horizontal, spacing: 16 do
          label "Port"
          @port = text_area text: settings[:network, :port].to_s, max_height: 30, width: $window.width / 2
        end

        button("Host") { push_game_state Server.new(port: @port.text.to_i) }
      end
     end
  end
end