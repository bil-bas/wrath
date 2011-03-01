class Bard < Knight
  def initialize(options = {})
    options = {
        animation: "bard_8x8.png",
    }.merge! options

    super options
  end
end