module CP
  class Space
    # Collision between a and b.
    def on_collision(a, b)
      raise "requires block" unless block_given?

      a, b = Array(a), Array(b)

      a.each do |c|
        b.each do |d|
          add_collision_handler(c, d) do |a, b|
            # Prevent collisions between objects that have already been destroyed.
            if a.object.exists? and b.object.exists?
              yield a.object, b.object
            else
              false
            end
          end
        end
      end
    end
  end
end