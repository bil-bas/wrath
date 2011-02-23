# encoding: utf-8

require_relative 'mob'

class Virgin < Mob
  def favor; 40; end

  def initialize(options = {})
    options = {
      vertical_jump: 0.05,
      horizontal_jump: 0.5,
      jump_delay: 500,
      encumbrance: 0.4,
      animation: "virgin_8x8.png",
    }.merge! options

    super options
  end

  def ghost_disappeared
    knight = Knight.create(spawn: true)
    $window.current_game_state.objects.push knight
    $window.current_game_state.objects.push Horse.create(x: knight.x, y: knight.y)
  end
end