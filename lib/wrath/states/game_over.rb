class GameOver < GameState
  def initialize(winner)
    @winner = winner
    super

    on_input(:escape) do
      game_state_manager.pop_until_game_state Menu
    end

    puts "Player ##{winner.number + 1} won"

    sparkle_frames = Animation.new(file: "sparkle_8x8.png")
    @sparkle = GameObject.create(image: sparkle_frames[winner.number],
                                 x: @winner.x, y: @winner.y - @winner.height / 2.0, zorder: @winner.y - 0.1, alpha: 150, mode: :additive)
  end

  def space
    previous_game_state.space
  end

  def network
    nil
  end

  def update
    previous_game_state.update

    super

    # Make the player and sparkle behind move upwards.
    rise = frame_time * 0.005
    @winner.z += rise
    @sparkle.y -= rise
    @sparkle.angle -= frame_time * 0.1
    @sparkle.factor = 1.5 + Math::sin(milliseconds / 1000.0) * 0.3
  end

  def draw
    previous_game_state.draw
    super
  end
end