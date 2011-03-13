class Paladin < Knight
  DAMAGE = 10 / 1000.0 # 10/second

  def initialize(options = {})
    options = {
        damage: DAMAGE,
        animation: "paladin_8x8.png",
    }.merge! options

    super options
  end
end