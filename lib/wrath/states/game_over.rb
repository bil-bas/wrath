module Wrath
class GameOver < Gui
  extend Forwardable
  trait :timer

  AVATAR_GLOW = Color.rgba(0, 255, 0, 150)

  def_delegators :previous_game_state, :space, :object_by_id, :objects, :network, :networked?, :client?, :host?, :tile_at_coordinate,
                 :send_message, :players, :draw_glow

  ACCEPTED_MESSAGES = [
      Message::EndGame
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

    horizontal spacing: 10, padding_top: $window.height - 75, padding_left: $window.width / 2 - 200 do
      button "Lobby", z: ZOrder::GUI, tip: "Return to the game lobby" do
        return_to_lobby
      end

      unless client?
        button "Play again", z: ZOrder::GUI, tip: "Replay this level with the same priests" do
          replay
        end

        if previous_game_state.class.next_level
          button "Play next", z: ZOrder::GUI, tip: "Play the next level with the same priests" do
            play_next
          end
        end
      end
    end
  end

  def end_game
    send_message Message::EndGame.new if networked?
  end

  def update_stats
    duration = (Time.now - previous_game_state.started_at).floor

    # Games played.
    level_completed = previous_game_state.class.name[/[^:]+$/].to_sym

    winner_name = if (host? and @winner.number == 0) or (client? and @winner.number == 1)
                    :local_player
                  elsif (host? and @winner.number == 1) or (client? and @winner.number == 0)
                    :remote_player
                  else
                    :"offline_player_#{@winner.number + 1}"
                  end

    statistics.increment(:levels, level_completed, :winner, winner_name)

    statistics.increment(:levels, level_completed, :played)

    statistics[:levels, level_completed, :duration] = (statistics[:levels, level_completed, :duration] || 0) + duration

    # Priests played.
    priests_played = [players[0].priest_name]
    priests_played << players[1].priest_name unless networked?
    priests_played.each do |priest|
      statistics.increment(:priests, priest)
    end

    group = [:played, networked? ? :online : :offline]
    statistics.increment(*group, :times)
    statistics[*group, :duration] = statistics[*group, :duration] + duration

    achievement_manager.save
    statistics.save
  end

  def return_to_lobby
    end_game
    pop_until_game_state Lobby
  end

  def replay
    end_game
    pop_game_state
    current_game_state.replay
  end

  def play_next
    end_game
    pop_game_state
    current_game_state.play_next_level
  end

  def setup
    super
    update_stats
  end

  def update
    network.update if networked?

    super

    @sparkle.angle -= frame_time * 0.1
    @sparkle.factor = 1.5 + Math::sin(milliseconds / 1000.0) * 0.3

    network.flush if networked?
  end

  def draw
    # Ensure the sparkle is cut off at ground level.
    $window.clip_to(0, 0, $window.width, @avatar.y) do
       @sparkle.draw
    end

    draw_glow(@avatar.x, @avatar.y, AVATAR_GLOW, @sparkle.factor)

    previous_game_state.draw

    super
  end
end
end