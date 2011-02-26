class EnterServerIP < GameState
  def initialize
    super

    @textinput = TextInput.new
    @textinput.text = "127.0.0.1"

    $window.text_input = @textinput
    on_input([:enter, :return], :done)

    @title = Text.create("Please enter server address:", size: 12)
    @ip = Text.create("", x: 0, y: 20, size: 20)
  end

  def update
    @ip.text = @textinput.text
  end

  def done
    push_game_state Client.new(address: @ip.text)
  end
end