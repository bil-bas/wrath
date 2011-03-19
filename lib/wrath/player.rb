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

    @gui_pos = [[10, 0], [115, 0]][@number]
    @font = Font[8]
    @visible = true

    super(options)

    on_input(@keys_action, :action) if local?
  end

  def win!
    if @state == :mounted
      @avatar.container.drop
    else
      @avatar.drop
    end
  end

  def lose!
    @avatar.container.drop if @state == :mounted
    @avatar.die!
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

    @favor
  end

  def opponent
    (parent.players - [self]).first
  end

  def update
    super

    move_by_keys if local? and avatar and not parent.winner
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
          moving.set_body_velocity(0, 0)
          # Standing entirely still.
        end
    end
  end

  def draw
    if avatar
      message = if parent.winner
                  if parent.winner == self
                    "Ascended"
                  else
                    "Died"
                  end
                else
                  "F: #{favor.to_i} H: #{@avatar.health.to_i}"
                end

      @font.draw message, *@gui_pos, ZOrder::GUI, 1, 1, STATUS_COLOR
    end
  end
end
end