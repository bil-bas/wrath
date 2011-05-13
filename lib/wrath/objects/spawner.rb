module Wrath
  class Spawner < StaticObject
    trait :timer

    public
    def initialize(options = {})
      options = {
          creatures: { Chicken => 5 },
          interval: 15000,
          spawn_offset: [0, 4, 0],
          spawn_velocity: [0, 1, 0.5],
          animation: "rock_6x6.png",
      }.merge! options

      @spawn_velocity = options[:spawn_velocity]
      @spawn_offset = options[:spawn_offset]
      @interval = options[:interval]
      @creatures = options[:creatures]

      super(options)

      self.factor *= 2

      next_spawn
    end

    protected
    def next_spawn
      after(@interval - (@interval / 2) + rand(@interval)) { generate } unless @client
    end

    protected
    def generate
      klass = @creatures.keys.sample
      max = @creatures[klass]
      if klass.all.size < max
        klass.create(position: [x + @spawn_offset[0], y + @spawn_offset[1], z + @spawn_offset[2]],
                     velocity: @spawn_velocity)
      end

      next_spawn
    end
  end
end