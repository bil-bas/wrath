module Wrath
  class Lobby < Gui

    READY_COLOR = Color.rgb(0, 0, 0)
    UNREADY_BACKGROUND_COLOR = Color.rgb(50, 50, 50)
    READY_BACKGROUND_COLOR = Color.rgb(0, 255, 0)
    DISAMBIGUATION_SUFFIX = '_'

    public
    def accept_message?(message); [Message::NewGame, Message::UpdateLobby].find {|m| message.is_a? m }; end

    public
    def initialize(network, opponent_name, self_name = nil)
      super()

      self_name = settings[:player, :name] unless self_name

      @network = network

      @player_names = [self_name, opponent_name]
      @player_names.reverse! if @network.is_a? Client
      @player_names[1] += DISAMBIGUATION_SUFFIX if @player_names[1] == @player_names[0]

      @player_number = host? ? 0 : 1

      on_input(:escape) { game_state_manager.pop_until_game_state Menu }

      heading = case @network
        when Server
          "Host"

        when Client
          @network.send_msg(Message::ClientReady.new(settings[:player, :name]))
          "Client"

        else
          "Lobby"
      end

      pack :vertical, spacing: 0 do
        label heading, font_size: 32

        player_grid

        level_picker
      end

      pack :horizontal do
        button "Cancel" do
          game_state_manager.pop_until_game_state Menu
        end

        if @network
          @ready_button = toggle_button("Ready") do |sender, value|
            update_ready @player_number, value
            send_message(Message::UpdateLobby.new(:ready, @player_number, value))
          end
        end

        if client?
          label "Wait for host to start a game"
        else
          @start_button = button("Start", enabled: local?) do
            new_game @level_picker.value
          end
        end
      end
    end

    def host?; @network.is_a? Server; end
    def client?; @network.is_a? Client; end
    def local?; @network.nil?; end

    def send_message(message)
      if client?
        @network.send_msg(message)
      else
        @network.broadcast_msg(message)
      end
    end

    protected
    def level_picker
      label "Level"

      pack :horizontal, spacing: 0 do
        @level_picker = combo_box value: Level.levels[0], width: $window.width * 0.6, padding: 0, enabled: (not client?) do
          Level.levels.each do |level|
            item(level.to_s, level)
          end

          subscribe :changed do |sender, level|
            send_message(Message::UpdateLobby.new(:level, level)) if host?
          end
        end

        label "", icon: Image["combo_arrow.png"], padding: 0
      end
    end

    protected
    def player_grid
      @ready_indicators = []
      @num_readies = 0

      label "Players"
      pack :grid, num_columns: 3, spacing_v: 4 do
        @player_names.each_with_index do |player_name, player_number|
          player_row player_name, player_number
        end
      end
    end

    protected
    def player_row(player_name, player_number)
      unless @priest_sprites
        @priest_sprites = Level::PRIEST_SPRITES.values.map do |file|
          ScaledImage.new(SpriteSheet.new(File.join('players', file), 8, 8)[0], $window.sprite_scale)
        end

        @player_sprite_combos = {}
      end

      is_local = ((player_number == @player_number) or local?)
      pack :horizontal, spacing: 0, padding: 0 do
        @player_sprite_combos[player_name] = combo_box width: 290, enabled: is_local do
          @priest_sprites.each_with_index do |sprite, i|
            item Level::PRIEST_NAMES[i].capitalize, i, icon: sprite
          end

          subscribe :changed do |sender, priest_index|
            enable_priest_options

            send_message(Message::UpdateLobby.new(:player, player_number, priest_index)) unless local?
          end
        end
        label "", icon: ScaledImage.new(Image["combo_arrow.png"], 1.5), padding: 0
      end

      # Do this afterwards, to force :changed event.
      @player_sprite_combos[player_name].value = player_number

      label player_name

      if @network
        @ready_indicators << label('Ready', color: READY_COLOR, background_color: UNREADY_BACKGROUND_COLOR)
      else
        label ''
      end
    end

    public
    # Start a new game. Also called from Message::NewGame.
    def new_game(level)
      if @network
        # Turn off the ready indicators, in case we come back to this state.
        2.times {|i| update_ready(i, false) }
        @ready_button.value = false
      end

      priest_files = @used_priests.map {|i| Level::PRIEST_SPRITES[Level::PRIEST_NAMES[i]] }
      push_game_state level.new(@network, @player_names, priest_files)
    end

    public
    def update
      @network.update if @network
      super
      @network.flush if @network
    end

    protected
    # Enables and disables all the possible priest sprites, based on what is available.
    def enable_priest_options
      @player_sprite_combos.values.each do |combo|
        @used_priests = @player_sprite_combos.values.map {|c| c.value }

        combo.each do |item|
          item.enabled = (not @used_priests.include?(item.value))
        end
      end
    end

    public
    def update_player(player_number, priest_index)
      @player_sprite_combos.values[player_number].value = priest_index
      enable_priest_options
    end

    public
    def update_level(level)
      @level_picker.value = level
    end

    public
    def update_ready(player_number, value)
      if value
        @num_readies += 1
      else
        @num_readies -= 1
      end

      if host?
        @start_button.enabled = (@num_readies == 2)
      end

      @ready_indicators[player_number].background_color = value ? READY_BACKGROUND_COLOR : UNREADY_BACKGROUND_COLOR
    end

    public
    def setup
      super
    end
  end
end