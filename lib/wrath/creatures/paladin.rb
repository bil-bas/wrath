class Paladin < Knight
  def initialize(options = {})
    options = {
        animation: "paladin_8x8.png",
    }.merge! options

    super options
  end
end