module Wrath
  # A sack which just spits out its contents when it is activated.
  # This is the most basic sort of "container that is destroyed when it is opened".
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
      possible_contents: [],
    }.merge! options

    super options

    unless parent.client?
      possible_contents = Array(options[:possible_contents])
      pick_up(possible_contents.sample.create(parent: parent))
    end
  end

    public
    def activated_by(actor)
      # Open the bag and spit out its contents. No need to sync the action, since
      # the drop/destroy will clean up for us.
      contents.position = self.position
      drop
      destroy
    end
  end
end