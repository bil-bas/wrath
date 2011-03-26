module Wrath
class PirateCaptain < Paladin
  DAMAGE = 10 / 1000.0

  def initialize(options = {})
    options = {
        damage: DAMAGE,
        animation: "pirate_captain_8x8.png",
    }.merge! options

    super options
  end
end
end