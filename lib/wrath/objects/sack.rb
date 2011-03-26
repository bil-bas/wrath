module Wrath
  # A sack which just spits out its contents when it is activated.
  class Sack < Container
    public
    def can_be_activated?(actor); actor.empty_handed?; end

    public
  def initialize(options = {})
    options = {
      hide_contents: true,
      drop_velocity: [0, 0, 1.2],
      factor: 0.7,
      animation: "sack_6x8.png",
    }.merge! options

    super options
  end

    public
    def activated_by(actor)
      @parent.send_message Message::PerformAction.new(actor, self) if parent.host?

      # Open the bag and spit out its contents.
      contents.position = self.position
      drop
      destroy
    end
  end
end