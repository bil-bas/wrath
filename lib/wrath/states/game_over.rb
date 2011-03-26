module Wrath
class GameOver < GameState
  extend Forwardable
  trait :timer

  AVATAR_GLOW = Color.rgba(0, 255, 0, 150)

  def_delegators :@play, :space, :object_by_id, :objects, :network, :networked?, :tile_at_coordinate, :send_message

  def accept_message?(message); [Message::Create, Message::Destroy, Message::EndGame, Message::SetHealth, Message::Sync].find {|m| message.is_a? m }; end

  def initialize(winner)
    @winner = winner
    @avatar = winner.avatar

    super

    # Since the avatar is paused, need to animate it from here.
    every(500) { @avatar.toggle_cheer }

    on_input(:escape) do
      send_message Message::EndGame.new if networked?
      game_state_manager.pop_until_game_state Lobby
    end

    log.info { "Player ##{winner.number + 1} won" }

    sparkle_frames = Animation.new(file: "objects/sparkle_8x8.png")
    @sparkle = GameObject.new(image: sparkle_frames[0],
                              x: @avatar.x, y: @avatar.y - @avatar.z - @avatar.height / 2.0,
                              zorder: @avatar.zorder, alpha: 150, mode: :additive)
  end

  def setup
    @play = previous_game_state
  end

  def update
    @play.update

    super

    @sparkle.angle -= frame_time * 0.1
    @sparkle.factor = 1.5 + Math::sin(milliseconds / 1000.0) * 0.3
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