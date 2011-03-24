module Wrath
  class Lobby < Gui
    public
    def accept_message?(message); [Message::NewGame].find {|m| message.is_a? m }; end

    public
    def initialize(network, opponent_name, self_name = nil)
      super()

      self_name = settings[:player, :name] unless self_name

      @network = network

      @player_names = [self_name, opponent_name]
      @player_names.reverse! if @network.is_a? Client
      @player_names[1] += ' ' if @player_names[1] == @player_names[0]

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

      pack :vertical, spacing: 16 do
        label heading, font_size: 32

        player_grid

        level_picker

        toggle_button("Ready") if @network

        if @network.is_a? Client
          label "Wait for host to start a game"
        else
          button("Start") { new_game @level_picker.value }
        end
      end
    end

    protected
    def level_picker
      label "Level"

      pack :horizontal do
        @level_picker = combo_box value: Play.levels[0], width: $window.width * 0.6 do
          Play.levels.each do |level|
            item(level.to_s, level)
          end
        end
      end
    end

    protected
    def player_grid
      label "Players"
      pack :grid, num_columns: 3, spacing_h: 16, spacing_v: 4 do
        @player_names.each_with_index do |player_name, player_number|
          player_row player_name, player_number
        end
      end
    end

    protected
    def player_row(player_name, player_number)
      unless @priest_sprites
        @priest_sprites = Play::PRIEST_SPRITES.values.map do |file|
          SpriteSheet.new(file, 8, 8)[0]
        end

        @player_sprite_combos = {}
      end

      @player_sprite_combos[player_name] = combo_box width: 200 do
        @priest_sprites.each_with_index do |sprite, i|
          item Play::PRIEST_NAMES[i].capitalize, i, icon: sprite
        end

        subscribe :changed do |sender, value|
          @player_sprite_combos.values.each do |combo|
            @used_priests = @player_sprite_combos.values.map {|c| c.value }

            combo.each do |item|
              item.enabled = (not @used_priests.include?(item.value))
            end
          end
        end
      end

      # Do this afterwards, to force :changed event.
      @player_sprite_combos[player_name].value = player_number

      label player_name

      if @network
        label 'Ready', background_color: Color.rgb(255, 0, 0)
      else
        label ''
      end
    end

    public
    # Start a new game. Also called from Message::NewGame.
    def new_game(level)
      priest_files = @used_priests.map {|i| Play::PRIEST_SPRITES[Play::PRIEST_NAMES[i]] }
      push_game_state level.new(@network, @player_names, priest_files)
    end

    public
    def update
      super
      @network.update if @network
    end
  end
end