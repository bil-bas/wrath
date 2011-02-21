class Client < GameStates::NetworkClient
  def initialize(options = {})
    options = {
      address: "127.0.0.1",
      port: 7778,
    }.merge! options

    connect(options[:address], options[:port])

    @font = Font[16]

    super options
  end

  def on_connect
    puts "Connected to server"
    $window.push_game_state Play
    #send_start
    #after(2000) { send_ping }
    #every(6000, name: :ping) { send_ping }
  end

  def draw
    @font.draw("Connecting...", 0, 0, ZOrder::GUI)
  end

  #
  # We override NetworkClient#on_msg and put our game logic there
  #
  def on_msg(msg)
    @packet_counter += 1

    case msg[:type]
      when :winner
        if @player.uuid == msg[:uuid]
          PuffText.create("YOU WON!")
        else
          PuffText.create("You LOST! #{msg[:alias]||msg[:uuid]} won.")
        end

      when :position
        player.x, player.y = msg[:x], msg[:y]
        player.previous_x, player.previous_y = msg[:previous_x], msg[:previous_y]
        player.alive = true

      when :destroy
        puts "Destroy: #{player.uuid}"
        player.destroy

      when :kill
        puts "* Kill: #{player.uuid} died @ #{msg[:x]}/#{msg[:y]}"
        player.alive = false

      when :restart
        player.alive = false
        restart

      when :ping
        send_msg(:type => :pong, :uuid => player.uuid, :milliseconds => msg[:milliseconds])

      when :pong
        @latency = (Gosu::milliseconds - msg[:milliseconds])
      end
  end
end