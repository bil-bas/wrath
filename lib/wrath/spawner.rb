module Wrath
  class Spawner < BasicGameObject
    include Log

    trait :timer

    public
    def initialize(creatures, options = {})
      options = {
          interval: 8000,
      }.merge! options

      @interval = options[:interval]
      @creatures = creatures

      super(options)

      next_spawn
    end

    protected
    def next_spawn
      # Interval is 0.5..1.5 times the default interval.
      after(@interval - (@interval / 2) + rand(@interval)) { generate } unless parent.client?
    end

    protected
    def generate
      # Create one of a random class, assuming there are not too many of them already on the map.
      @creatures.keys.shuffle.each do |klass|
        max_of_class = @creatures[klass]
        if klass.all.size < max_of_class
          object = klass.create
          object.z = 20
          break
        end
      end

      next_spawn
    end
  end
end