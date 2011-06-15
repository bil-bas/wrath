module Wrath
  class Spawner < BasicGameObject
    include Log

    trait :timer

    # Object classes that can be spawned by this spawner.
    def spawnable_objects; @spawn_caps.keys; end

    # Are there more initial spawn objects yet to be created?
    def initial_spawns_left?; not @initial_spawns.empty? end

    public
    def initialize(level_class, options = {})
      options = {
          interval: 8000,
      }.merge! options

      @interval = options[:interval]

      # Create objects to create (slowly) during the setup period.
      klass = Inflector.underscore(Inflector.demodulize(level_class.name))
      spawn_data = YAML.load(File.read(File.join(EXTRACT_PATH, "config/levels/#{klass}.yml")))[:objects]

      @initial_spawns = []
      @spawn_caps = {}
      @possible_contents = {}
      spawn_data.each_pair do |klass_name, data|
        klass = Wrath.const_get(klass_name)
        @initial_spawns += [klass] * data[:initial]
        @spawn_caps[klass] = data[:cap] if data.has_key? :cap
        if data.has_key? :contents
          contents = spawn_data[klass_name][:contents]
          @possible_contents[klass] = contents.map {|c| Wrath.const_get(c) }
        end
      end

      super(options)

      schedule_spawn
    end

    def spawn_initial(number)
      @initial_spawns.shift(number).each do |klass|
        klass.create(parent: parent, possible_contents: @possible_contents[klass])
      end

      nil
    end

    protected
    def schedule_spawn
      # Interval is 0.5..1.5 times the default interval.
      after(@interval - (@interval / 2) + rand(@interval)) { spawn } unless parent.client?
    end

    protected
    def spawn
      # Create one of a random class, assuming there are not too many of them already on the map.
      @spawn_caps.keys.shuffle.each do |klass|
        max_of_class = @spawn_caps[klass]
        if klass.all.size < max_of_class
          klass.create(z_velocity: 1.5, parent: parent)
          break
        end
      end

      schedule_spawn
    end
  end
end