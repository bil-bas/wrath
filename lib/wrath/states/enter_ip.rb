module Wrath
class EnterServerIP < GameState
  def initialize
    super

    @textinput = TextInput.new
    @textinput.text = setting(:network_address)

    $window.text_input = @textinput
    on_input([:enter, :return]) do
      push_game_state Client.new(address: @ip.text, port: setting(:network_port))
    end
    on_input(:escape) { pop_game_state }

    @title = Text.create("Please enter server address:", size: 12)
    @ip = Text.create("", x: 0, y: 20, size: 20)
  end

  def update
    @ip.text = @textinput.text
  end
end
end