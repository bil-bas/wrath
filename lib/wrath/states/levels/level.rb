module Wrath
class Level < GameState
  extend Forwardable

  unless defined? GRAVITY
    GRAVITY = -4 / 1000.0 # Acceleration per second.

    SYNCS_PER_SECOND = 10.0 # Desired speed for sync updates.
    SYNC_DELAY = 0 # 1000.0 / SYNCS_PER_SECOND
    IDEAL_PHYSICS_STEP = 1.0 / 240.0 # Physics frame-rate.
    DARKNESS_COLOR = Color.rgba(0, 0, 0, 120)
    GLOW_WIDTH = 64
    MIN_DISTANCE_FROM_PLAYER_TO_SPAWN = 28
  end

  # Messages accepted after the game has started.
  GAME_STARTED_MESSAGES = [
      Message::ApplyStatus,
      Message::Create,
      Message::Destroy,
      Message::EndGame,
      Message::GodLoves,
      Message::KnockedDown,
      Message::PerformAction,
      Message::RemoveStatus,
      Message::RequestAction,
      Message::StandUp,
      Message::Sync,
      Message::Teleport,
      Message::SetAnger, Message::SetFavor, Message::SetHealth
  ]

  # Messages accepted during the setup phase.
  GAME_SETUP_MESSAGES = [
      Message::ApplyStatus,
      Message::Create,
      Message::EndGame,
      Message::Map,
      Message::PerformAction,
      Message::StartGame
  ]

  # Margin in which nothing should spawn.
  module Margin
    TOP = 20
    BOTTOM = 0
    LEFT = 0
    RIGHT = 0
  end
  
  LEVELS = [Forest, Cave, Island, Ship, Undersea, Desert, Facility, Moon]

  def_delegators :@map, :tile_at_coordinate

  attr_reader :objects, :god, :map, :players, :network, :space, :altar, :winner, :started_at, :spawner

  attr_accessor :screen_offset_y

  def self.t; R18n.get.t.level[Inflector.underscore(Inflector.demodulize(name))]; end
  def t; self.class.t; end

  def self.to_s; t.name; end
  def altar=(altar); @objects << altar; @altar = altar; end
  def medium; :air; end
  def networked?; !!@network; end
  def host?; @network.is_a? Server; end
  def client?; @network.is_a? Client; end
  def local?; @network.nil?; end
  def started?; @started; end
  def gravity; GRAVITY; end
  def self.icon
    short_name = Inflector.underscore(Inflector.demodulize(name))
    unlocked? ? Image["levels/#{short_name}.png"] : Image["levels/locked/#{short_name}.png"]
  end

  def self.next_level
    if self == LEVELS.last
      nil
    else
      LEVELS[LEVELS.index(self) + 1]
    end
  end

  # network: Server, Client, nil
  def initialize(network = nil, god_class, player_names, priest_names)
    BaseObject.reset_object_ids

    @@glow = make_glow

    @network, @god_class, @player_names, @priest_names =
        network, god_class, player_names, priest_names

    super()

    send_message(Message::NewGame.new(self.class, @god_class)) if host?

    @last_sync = milliseconds

    init_physics

    @clear_tiles = []
    @winner = nil
    @objects = []
    @players = []
    @started = false
    @screen_offset_y = 0

    @font = Font[$window.class::FONT, 9]

    create_players

    unless client?
      tiles = random_tiles
      create_map(tiles)
      send_message(Message::Map.new(tiles)) if host?
    end

    log.info "Initiated '#{self}'"
  end

  def setup
    super

    if networked?
      on_input(controls[:general, :toggle_network]) do
        @network_overlay ||= $window.add_overlay NetworkOverlay.new(@network)
        @network_overlay.toggle
      end
    end

    on_input(controls[:general, :menu]) do
      push_game_state GameMenu
    end

    on_input(controls[:general, :toggle_fps]) do
      @fps_overlay ||= $window.add_overlay FPSOverlay.new
      @fps_overlay.toggle
    end

    players.each(&:setup_inputs)

    log.info "Started playing"
  end

  def finalize
    input.clear
    log.info "Stopped playing"
  end
  
  def self.unlocked?
    $window.achievement_manager.unlocked?(:level, name[/[^:]+$/].to_sym)
  end
  
  def replay
    log.info { "Replaying #{self.class}" }
    switch_game_state self.class.new(@network, @god_class, @player_names, @priest_names)
  end

  def play_next_level
    log.info { "Moving on to next level from #{self.class}" }
    next_level = self.class.next_level
    switch_game_state(next_level.new(@network, next_level::GOD, @player_names, @priest_names))
  end

  def accept_message?(message)
    accepted_messages = started? ? GAME_STARTED_MESSAGES : GAME_SETUP_MESSAGES

    accepted_messages.find {|m| message.is_a? m }
  end

  def create_map(tiles)
    @map = Map.create(tiles)
  end

  # Find the next clear spawn position to place a newly created object.
  def next_spawn_position(object)
    if @clear_tiles.empty?
      @clear_tiles = @map.tiles.flatten
      @clear_tiles.reject! {|tile| tile.y < 20 } # Get rid of top two rows.
      # Not too close to either player.
      @clear_tiles.reject! do |tile|
        @players.any? {|player| player.avatar.distance_to(tile) < MIN_DISTANCE_FROM_PLAYER_TO_SPAWN }
      end
      @clear_tiles.shuffle!
    end

    while free_tile = @clear_tiles.pop
      if object.can_spawn_onto?(free_tile)
        return [free_tile.x, free_tile.y, free_tile.z]
      else
        @clear_tiles.unshift free_tile
      end
    end
  end

  # Start the game, after sending all the init data.
  def start_game
    log.info "Started game on #{self}"
    @god = @god_class.create
    @started = true
    @started_at = Time.now
  end

  def send_message(message)
    if client?
      @network.send_msg(message)
    else
      @network.broadcast_msg(message)
    end
  end

  def create_players
    log.info "Creating players"

    @players << Player.create(0, (not client?), @priest_names[0])
    @players << Player.create(1, (not host?), @priest_names[1])
  end

  def init_physics
    log.info "Initiating physics"


    @physics_time = 0.0 # Time to use for calculating physics.

    @space = CP::Space.new
    @space.damping = 0

    # Wall around the play-field.
    y_margin = 16
    [
      [0, 0, 0, $window.height, :left],
      [0, $window.height, $window.width, $window.height, :bottom],
      [$window.width, 0, $window.width, $window.height, :right],
      [0, y_margin, $window.width, y_margin, :top]
    ].each do |x1, y1, x2, y2, side|
      Wall.create(x1, y1, x2, y2, side)
    end

    # :static - An immobile object that blocks all movement.
    # :wall - Edge of the screen.
    # :object - players, mobs and carriable objects.
    # :scenery - Doesn't collide with anything at all.


    @space.on_collision(:particle, [:static, :object]) do |a, b|
      if (a.z > b.z + b.collision_height) or (b.z > a.z + a.collision_height)
        false
      else
        a.on_collision(b)
      end
    end

    # Objects collide with static objects, unless they are being carried or heights are different.
    @space.on_collision(:object, :static) do |a, b|
      not (a.inside_container? or (a.z > b.z + b.collision_height) or (b.z > a.z + a.collision_height))
    end

    # Objects collide with the wall, unless they are being carried.
    @space.on_collision(:object, :wall) do |object, wall|
      object.on_collision(wall)
    end

    @space.on_collision(:object, :object) do |a, b|
      # Objects only affect one another on the host/local machine and only if they touch vertically.
      if client?
        false
      elsif not ((a.z > b.z + b.collision_height) or (b.z > a.z + a.collision_height))
        collides = a.on_collision(b)
        collides ||= b.on_collision(a)

        collides
      end
    end
  end

  def create_altar
    # The altar is all-important!
    Altar.create(x: $window.width / 2, y: ($window.height + Margin::TOP) / 2)
  end

  def create_objects
    log.info "Creating objects"

    @altar = create_altar
    @objects << @altar # Needs to be added manually, since it is a static object.

    # Player 1.
    player1 = Priest.create(name: @priest_names[0], local: true, x: altar.x - 12, y: altar.y,
                            factor_x: 1)
    players[0].avatar = player1

    # Player 2.
    player2 = Priest.create(name: @priest_names[1], local: @network.nil?, x: altar.x + 12, y: altar.y,
                            factor_x: -1)
    players[1].avatar = player2

    @spawner = Spawner.create(self.class)
  end

  def random_tiles(default_tile)
    # Fill the grid with grass to start with.
    num_columns, num_rows = ($window.width / Tile::WIDTH).ceil, ($window.height / Tile::HEIGHT).ceil
    grid = Array.new(num_rows) { Array.new(num_columns, default_tile) }

    [num_columns, num_rows, grid]
  end

  def update
    # Read any incoming messages which will alter our start state.
    @network.update if @network

    if started?
      super

      objects.each {|o| o.update_forces }

      # Ensure that we have one or more physics steps that run at around the same interval.
      @physics_time += frame_time / 1000.0
      num_steps = (@physics_time / IDEAL_PHYSICS_STEP).round
      @physics_time -= num_steps * IDEAL_PHYSICS_STEP
      num_steps.times do
        @space.step IDEAL_PHYSICS_STEP
      end

      # Move carried objects to appropriate positions to prevent desync in movement.
      @objects.each do |object|
        if object.is_a? Container and object.full?
          object.update_contents_position
        end
      end
    else
      if map
        if map.tiles_to_create? # Create a couple of tiles.
          # Client must create all at once, otherwise might not be ready for the host sending objects!
          map.create_tiles(client? ? 100000 : 10)
        elsif map.incomplete? # All the tiles have been created, splice them onto the background.
          map.generate_background
        elsif not client? # Create some objects!
          # Create objects until we are ready to start the level.
          # Don't update at this point, since we don't want them interacting yet.
          if Altar.all.empty?
            create_objects
          elsif @spawner.initial_spawns_left?
            @spawner.spawn_initial(5)
          else
            send_message(Message::StartGame.new) if host?
            start_game
          end
        end
      end
    end

    # Ensure that any network objects are synced over the network.
    if @network
      sync if started?
      @network.flush
    end
  end

  def draw
    if started?
      if screen_offset_y == 0
        super
      else
        $window.translate(0, screen_offset_y) do
          super
        end
      end
    else
      dots = '.' * ((milliseconds / 500.0) % 7).to_i
      @font.draw("Loading#{dots}", 2.5, 2.5, ZOrder::GUI)
    end
  end

  # A player has declared themselves the loser, so the other player wins.
  def lose!(loser)
    win!(loser.opponent)
  end

  # A player has declared themselves the winner.
  def win!(winner)
    @winner = winner
    @winner.win!
    @winner.opponent.lose!

    # Ensure that if we have any game-states above us, that we always push the GameOver directly on top of us.
    game_state_manager.pop_until_game_state self
    push_game_state GameOver.new(winner)
  end

  def make_glow
    @@glow = TexPlay.create_image($window, GLOW_WIDTH, GLOW_WIDTH)
    @@glow.refresh_cache

    center = @@glow.width / 2.0
    radius =  @@glow.width / 2.0

    @@glow.circle center, center, radius, :filled => true,
      :color_control => lambda {|source, dest, x, y|
        # Glow starts at the edge of the pixel (well, its radius, since glow is circular, not rectangular)
        distance = distance(center, center, x, y)
        dest[3] = (1 - (distance / radius)) ** 2
        dest
      }
  end

  def draw_glow(x, y, color, scale)
    @@glow.draw_rot(x, y, ZOrder::BACK_GLOW, 0, 0.5, 0.5, scale, scale, color, :additive)
  end

  def sync
    if (milliseconds - @last_sync) >= SYNC_DELAY
      needs_sync = objects.select {|o| o.network_sync? }
      sync = Message::Sync.new(needs_sync)
      unless sync.empty?
        length = send_message(sync)

        log.debug { "Synchronised #{needs_sync.size} objects in #{length} bytes" }
      end
      @last_sync = milliseconds
    end
  end

  def popped
    game_objects.each {|obj| obj.class.instances.delete obj }
    $window.remove_overlay @network_overlay if @network_overlay
  end
end
end