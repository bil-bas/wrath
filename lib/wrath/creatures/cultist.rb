module Wrath
class Cultist < Knight
  def initialize(options = {})
    options = {
        animation: "cultist_8x8.png",
        encumbrance: 0.4,
    }.merge! options

    super options
  end
end
end