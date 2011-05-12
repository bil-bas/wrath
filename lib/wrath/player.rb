module Wrath

# A player that controls a creature in the game.
class Player < BasicGameObject
  include Log
  extend Forwardable
  include Helpers::InputClient

  STATUS_COLOR = Color.rgba(255, 255, 255, 150)

  KEYS_CONFIG_FILE = 'keys.yml'

  INITIAL_FAVOR = 0
  FAVOR_TO_WIN = 100

  HEALTH_BAR_COLOR = Color.rgb(255, 0, 0)
  FAVOR_BAR_COLOR = Color.rgb(200, 200, 255)

  attr_reader :number, :avatar, :favor, :visible

  def local?; @local; end
  def remote?; not @local; end

  def initialize(number, local, options = {})
    options = {
        favor: INITIAL_FAVOR,
    }.merge! options

    @favor = options[:favor]

    @number, @local = number, local

    @@keys_config ||= Settings.new(KEYS_CONFIG_FILE)

    @keys_left = @@keys_config[:players, @number + 1, :left]
    @keys_right = @@keys_config[:players, @number + 1, :right]
    @keys_up = @@keys_config[:players, @number + 1, :up]
    @keys_down = @@keys_config[:players, @number + 1, :down]
    @keys_action = @@keys_config[:players, @number + 1, :action]

    @gui_pos = [[20, 1], [130 + Humanoid::PORTRAIT_WIDTH, 1]][@number]
    @font = Font["pixelated.ttf", 32]
    @visible = true

    @health_bar = Bar.create(x: @gui_pos[0], y: @gui_pos[1], color: HEALTH_BAR_COLOR)
    @favor_bar = Bar.create(x: @gui_pos[0], y: @gui_pos[1] + 3, color: FAVOR_BAR_COLOR)

    super(options)

    on_input(@keys_action, :action) if local?
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

    @favor_bar.value = @favor.to_f / FAVOR_TO_WIN

    @favor
  end

  def opponent
    (parent.players - [self]).first
  end

  def update
    super

    if avatar
      @health_bar.value = avatar.health.to_f / avatar.max_health

      move_by_keys if local? and not parent.winner
    end
  end

  def action
    return unless avatar and not parent.winner

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

      portrait = avatar.portrait
      portrait.draw @gui_pos[0] - portrait.width, @gui_pos[1], ZOrder::GUI
    end
  end
end
end