module Wrath
class GameOver < GameState
  extend Forwardable

  def_delegators :@play, :space, :object_by_id, :objects, :network

  def initialize(winner)
    @winner = winner
    @avatar = winner.avatar

    super

    on_input(:escape) do
      if @play.client?
        game_state_manager.pop_until_game_state Menu
      else
        # Remove this state and then restart the Play.
        pop_game_state
        @play.restart
      end
    end

    log.info { "Player ##{winner.number + 1} won" }

    sparkle_frames = Animation.new(file: "sparkle_8x8.png")
    @sparkle = GameObject.create(image: sparkle_frames[winner.number],
                                 x: @avatar.x, y: @avatar.y - @avatar.height / 2.0,
                                 zorder: @avatar.y - 0.1, alpha: 150, mode: :additive)
  end

  def setup
    @play = previous_game_state
  end

  def update
    @play.update

    super

    # Make the player and sparkle behind move upwards.
    rise = frame_time * 0.005
    @avatar.z += rise
    @sparkle.y -= rise
    @sparkle.angle -= frame_time * 0.1
    @sparkle.factor = 1.5 + Math::sin(milliseconds / 1000.0) * 0.3
  end

  def draw
    @play.draw
    super
  end
end
end