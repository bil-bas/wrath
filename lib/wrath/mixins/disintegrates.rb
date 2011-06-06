module Wrath
  # Makes an object fade out after it has been destroyed.
  module Disintegrates
    # Object that does the fading.
    class Disintegration < GameObject
      trait :timer

      COPIED_ATTRIBUTES = [:x, :y, :zorder, :color, :factor_x, :factor_y, :parent, :image]
      FADE_SPEED = 255 / 1000.0 # Takes 1s to disappear.

      def initialize(original)
        options = { rotation_center: :bottom_center }

        COPIED_ATTRIBUTES.each do |attribute|
          value = original.send(attribute)
          value = value.dup if value.is_a? Color
          options[attribute] = value
        end

        options[:y] -= original.z

        $window.log.debug options.inspect

        super(options)

        @float_alpha = alpha
      end

      def update
        @float_alpha -= FADE_SPEED * parent.frame_time
        if @float_alpha <= 0
          destroy
        else
          self.alpha = @float_alpha.to_i
          super
        end
      end
    end

    DEFAULT_DISINTEGRATE_DELAY = 10 * 1000

    # Override this to change the decay period.
    def disintegrate_delay; DEFAULT_DISINTEGRATE_DELAY; end

    def self.included(base)
      base.trait :timer
    end

    def initialize(options = {})
      super(options)

      schedule_disintegration
    end

    def schedule_disintegration
      after(disintegrate_delay, name: :disintegrate) { disintegrate } unless parent.client?
    end

    def on_being_picked_up(container)
      super
      stop_timer :disintegrate
    end

    def on_stopped
      super
      schedule_disintegration
    end

    def disintegrate
      Disintegration.create(self)
      destroy
    end
  end
end