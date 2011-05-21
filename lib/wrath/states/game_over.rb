module Wrath
class GameOver < Gui
  extend Forwardable
  trait :timer

  AVATAR_GLOW = Color.rgba(0, 255, 0, 150)

  def_delegators :@play, :space, :object_by_id, :objects, :network, :networked?, :client?, :host?, :tile_at_coordinate,
                 :send_message, :players

  ACCEPTED_MESSAGES = [
      Message::Create,
      Message::Destroy,
      Message::EndGame,
      Message::SetHealth,
      Message::Sync
  ]

  def accept_message?(message); ACCEPTED_MESSAGES.find {|m| message.is_a? m }; end

  def initialize(winner)
    @winner = winner
    @avatar = winner.avatar

    super()

    # Since the avatar is paused, need to animate it from here.
    every(500) { @avatar.toggle_cheer }

    on_input(:escape) do
      return_to_lobby
    end

    log.info { "Player ##{winner.number + 1} won" }

    sparkle_frames = Animation.new(file: "objects/sparkle_8x8.png")
    @sparkle = GameObject.new(image: sparkle_frames[0],
                              x: @avatar.x, y: @avatar.y - @avatar.z - @avatar.height / 2.0,
                              zorder: @avatar.zorder, alpha: 150, mode: :additive)

    pack :horizontal, spacing: 10, padding_top: 430, padding_h: 220 do
      unless previous_game_state.client?
        button "Play again", z: ZOrder::GUI, tip: "Replay this level with the same priests" do
          replay
        end
      end

      button "Lobby", z: ZOrder::GUI, tip: "Return to the game lobby" do
        return_to_lobby
      end
    end
  end

  def end_game
    send_message Message::EndGame.new if networked?
  end

  def update_stats
    # Games played.
    level_completed = previous_game_state.class.name[/[^:]+$/].to_sym

    if (host? and @winner.number == 0) or (client? and @winner.number == 1)
      statistics.increment(:levels, level_completed, :online_won)
    elsif (host? and @winner.number == 1) or (client? and @winner.number == 0)
      statistics.increment(:levels, level_completed, :online_lost)
    else
      statistics.increment(:levels, level_completed, :"offline_player_#{@winner.number + 1}_won")
    end

    # Priests played.
    priests_played = [players[0].priest_name]
    priests_played << players[1].priest_name unless networked?
    priests_played.each do |priest|
      statistics.increment(:priests, priest)
    end

    statistics.save
  end

  def return_to_lobby
    end_game
    game_state_manager.pop_until_game_state Lobby
  end

  def replay
    end_game
    pop_game_state
    current_game_state.replay
  end

  def setup
    super
    @play = previous_game_state
    update_stats
  end

  def update
    @network.update if @network

    super

    @sparkle.angle -= frame_time * 0.1
    @sparkle.factor = 1.5 + Math::sin(milliseconds / 1000.0) * 0.3

    @network.flush if @network
  end

  def draw
    # Ensure the sparkle is cut off at ground level.
    $window.clip_to(0, 0, $window.width, @avatar.y) do
       @sparkle.draw
    end

    previous_game_state.draw_glow(@avatar.x, @avatar.y, AVATAR_GLOW, @sparkle.factor)

    @play.draw

    super
  end
end
end