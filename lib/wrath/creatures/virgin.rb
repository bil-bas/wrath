# encoding: utf-8

require_relative 'mob'

class Virgin < Mob
  IMAGE_ROW = 4

  def favor; 30; end

  def initialize(options = {})
    options = {
      speed: 0.3,
      encumbrance: 0.4,
    }.merge! options

    super IMAGE_ROW, options
  end

  def ghost_disappeared
    $window.current_game_state.mobs.push Knight.create(spawn: true)
  end
end