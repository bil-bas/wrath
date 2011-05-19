module Wrath

# A player that controls a creature in the game.
class Player < BasicGameObject
  include Log
  extend Forwardable
  include Helpers::InputClient

  STATUS_ICON_SCALE = 0.5
  STATUS_COLOR = Color.rgba(255, 255, 255, 150)
  BACKGROUND_COLOR = Color.rgba(0, 0, 0, 100)

  KEYS_CONFIG_FILE = 'keys.yml'

  INITIAL_FAVOR = 0
  FAVOR_TO_WIN = 100

  HEALTH_BAR_COLOR = Color.rgb(255, 0, 0)
  FAVOR_BAR_COLOR = Color.rgb(200, 200, 255)
  PADDING = 1

  attr_reader :number, :avatar, :favor, :visible

  def local?; @local; end
  def remote?; not @local; end

  def initialize(number, local, options = {})
    options = {
        favor: INITIAL_FAVOR,
    }.merge! options

    @favor = options[:favor]

    @number, @local = number, local

    @gui_pos = [[30, 1], [130 + Humanoid::PORTRAIT_WIDTH, 1]][@number]
    @font = Font["pixelated.ttf", 32]
    @visible = true

    @health_bar = Bar.new(x: @gui_pos[0] + PADDING, y: @gui_pos[1] + PADDING, color: HEALTH_BAR_COLOR)
    @favor_bar = Bar.new(x: @gui_pos[0] + PADDING, y: @gui_pos[1] + PADDING + @health_bar.height, color: FAVOR_BAR_COLOR)

    super(options)

    if local?
      keys_config = Settings.new(KEYS_CONFIG_FILE)
      group = parent.networked? ? :network_player : :"local_player_#{@number + 1}"
      @keys_left = keys_config[group, :left]
      @keys_right = keys_config[group, :right]
      @keys_up = keys_config[group, :up]
      @keys_down = keys_config[group, :down]
      @keys_action = keys_config[group, :action]

      on_input(@keys_action, :action)
    end
  end

  def win!
    game_over
  end

  def lose!
    game_over
  end

  def game_over
    if @state == :mounted
      @avatar.container.drop
    else
      @avatar.drop
    end

    @avatar.reset_forces
    @avatar.pause!
  end

  def avatar=(creature)
    @avatar.player = nil if @avatar
    @avatar = creature
    @avatar.player = self if @avatar
  end

  def favor=(value)
    original_favor = @favor

    @favor = [[value, 0].max, FAVOR_TO_WIN].min
    parent.win!(self) if @favor == FAVOR_TO_WIN and not parent.winner

    # Synchronise favor from the host to the client.
    if @favor != original_favor and parent.host?
      parent.send_message(Message::SetFavor.new(self))
    end

    if @favor > original_favor
      parent.god.give_favor(@favor - original_favor)
    end

    @favor_bar.value = @favor.to_f / FAVOR_TO_WIN

    @favor
  end

  def opponent
    (parent.players - [self]).first
  end

  def update
    super

    if avatar and avatar.parent
      @health_bar.value = avatar.health.to_f / avatar.max_health

      move_by_keys if local? and not parent.winner
    end
  end

  def action
    return unless avatar and avatar.parent and not parent.winner

    case avatar.state
      when :carried, :mounted
        @avatar.container.drop

      when :standing, :walking
        @avatar.action
    end
  end

  def move_by_keys
    moving = if avatar.state == :mounted
               avatar.container
             else
               avatar
             end

    case avatar.state
      when :standing, :walking, :mounted
        if holding_any? *@keys_left
          if holding_any? *@keys_up
            # NW
            moving.move(315)
          elsif holding_any? *@keys_down
            # SW
            moving.move(225)
          else
            # W
            moving.move(270)
          end
        elsif holding_any? *@keys_right
          if holding_any? *@keys_up
            # NE
            moving.move(45)
          elsif holding_any? *@keys_down
            # SE
            moving.move(135)
          else
            # E
            moving.move(90)
          end
        elsif holding_any? *@keys_up
          # N
          moving.move(0)
        elsif holding_any? *@keys_down
          # S
          moving.move(180)
        else
          moving.halt
        end
    end
  end

  def draw
    if avatar
      portrait = avatar.portrait

      # Draw background and bars.
      $window.pixel.draw(@gui_pos[0] - portrait.width, @gui_pos[1], ZOrder::GUI,
                         portrait.width + @health_bar.width + PADDING * 2, 8, BACKGROUND_COLOR)

      @health_bar.draw
      @favor_bar.draw

      # Portrait of avatar.
      portrait.draw @gui_pos[0] - portrait.width, @gui_pos[1], ZOrder::GUI

      # List of status effects.
      x = @gui_pos[0] + PADDING
      @avatar.statuses.each do |status|
        icon = status.image
        icon.draw  x, @gui_pos[1] + 5.25, ZOrder::GUI, STATUS_ICON_SCALE, STATUS_ICON_SCALE
        x += icon.width * STATUS_ICON_SCALE + PADDING
      end

      # Text message over the top.
      message = if parent.winner
                  if parent.winner == self
                    "Won!"
                  else
                    "Lost!"
                  end
                else
                  ""
                end

      @font.draw_rel message, *@gui_pos, ZOrder::GUI, 0, 0, 0.25, 0.25, STATUS_COLOR
    end
  end
end
end