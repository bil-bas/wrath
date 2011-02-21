# encoding: utf-8

require_relative 'mob'

class Virgin < Mob
  IMAGE_ROW = 4

  def favor; 40; end

  def initialize(options = {})
    options = {
      vertical_jump: 0.05,
      horizontal_jump: 0.5,
      jump_delay: 500,
      encumbrance: 0.4,
    }.merge! options

    super IMAGE_ROW, options
  end

  def ghost_disappeared
    $window.current_game_state.mobs.push Knight.create(spawn: true)
  end
end