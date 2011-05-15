module Wrath
  class Container < DynamicObject
    attr_reader :contents

    def empty?; @contents.nil?; end
    def full?; not empty?; end
    def on_having_dropped(object); end
    def on_having_picked_up(object); end

    public
    def initialize(options = {})
      options = {
          contents_offset: [0, 0, 0],
          hide_contents: false,
          drop_velocity: [0, 0, 0],
      }.merge! options

      @contents_offset = options[:contents_offset]
      @drop_velocity = options[:drop_velocity]
      @hide_contents = options[:hide_contents]

      # Pick one of the contents objects, creating if it is a class rather than an object.
      to_be_contents = if options[:contents]
                    possible_objects = Array(options[:contents])
                    object = possible_objects.sample
                    object = object.create(x: -100 * rand(100), y: -100 * rand(100)) if object.is_a? Class
                    object

                  elsif options[:contents_id]
                    parent = options[:parent] || $window.current_game_state
                    parent.object_by_id(options[:contents_id])

                  else
                    nil
                  end

      super(options)

      @contents = nil

      pick_up(to_be_contents) if to_be_contents
    end

    public
    # This is called by Message::PerformAction or when host/local player tries to do something.
    def perform_action(target)
     if target
        target.activated_by(self)
      else
        drop
      end
    end

    public
    # This is called by Message::RequestAction
    def request_action(target)
      # For now, this does the same thing.
      perform_action(target)
    end

    public
    # Pick up an object.
    def pick_up(object)
      drop unless empty?

      parent.send_message(Message::PerformAction.new(self, object)) if parent.host?

      @contents = object
      if @hide_contents
        @contents.pause!
        @contents.z = 10000
      end
      @contents.velocity = [0, 0, 0]
      @contents.local = local? if not @contents.controlled_by_player?
      @contents.reset_forces
      update_contents_position

      @contents.picked_up_by(self)
      on_having_picked_up(@contents)
    end

    public
    def drop
      return unless @contents

      @parent.send_message Message::PerformAction.new(self) if parent.host?

      to_drop = @contents
      @contents = nil

      to_drop.local = (not parent.client?) unless to_drop.controlled_by_player?
      to_drop.unpause!
      to_drop.velocity = [x_velocity + @drop_velocity[0], y_velocity + @drop_velocity[1], z_velocity + @drop_velocity[2]]

      to_drop.dropped
      on_having_dropped(to_drop)
    end

    public
    # Called from the game-state, once all updates are complete, to ensure syncing between carried objects.
    def update_contents_position
      unless @hide_contents
        # The x-offset assumes container/contents are facing to the right.
        x_sign = factor_x > 0 ? +1 : -1
        @contents.position = [
            x + (@contents_offset[0]) * x_sign,
            y + @contents_offset[1] + 0.00001,
            z + height + @contents.z_offset + @contents_offset[2]
        ]
      end
    end
  end
end