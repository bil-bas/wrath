# encoding: utf-8

class Transition < GameStates::FadeTo
  def initialize(state)
    super(state, speed: 3)
  end

  # Ensure that particles keep moving.
  def update
    super
    previous_game_state.update(false) if previous_game_state
  end

  # Ensure that particles keep moving.
  def draw
    super
    previous_game_state.draw if previous_game_state
  end
end