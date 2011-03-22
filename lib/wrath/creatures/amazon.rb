module Wrath
class Amazon < Knight
  def initialize(options = {})
    options = {
        animation: "amazon_8x8.png",
    }.merge! options

    super options
  end
end
end