# encoding: utf-8

require_relative 'mob'

class Virgin < Mob
  def favor; 30; end

  def initialize(options = {})
    options = {
      image: $window.character_sprites[2, 1],
      speed: 0.3,
      encumbrance: 0.4,
    }.merge! options

    super options
  end

  def ghost_disappeared
    $window.current_game_state.mobs.push Knight.create(spawn: true)
  end
end