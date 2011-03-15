module Wrath

# A player that controls a creature in the game.
class Player < BasicGameObject
  extend Forwardable
  include Helpers::InputClient

  STATUS_COLOR = Color.rgba(255, 255, 255, 150)

  KEYS_CONFIG_FILE = File.join(ROOT_PATH, 'config', 'keys.yml')

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

    keys_config = YAML.load(File.open(KEYS_CONFIG_FILE) {|f| f.read })

    keys = keys_config[:players][@number + 1]
    @keys_left = keys[:left]
    @keys_right = keys[:right]
    @keys_up = keys[:up]
    @keys_down = keys[:down]
    @keys_action = keys[:action]

    @gui_pos = [[10, 0], [115, 0]][@number]
    @font = Font[8]
    @visible = true

    super(options)

    on_input(@keys_action, :action) if local?
  end

  def win!
    @avatar.drop
    @avatar.pause!
  end

  def lose!
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

    move_by_keys if local? and avatar
  end

  def action
    return unless avatar

    case avatar.state
      when :carried
        @avatar.carrier.drop

      when :standing, :walking
        @avatar.action
    end
  end

  def move_by_keys
    case avatar.state
      when :standing, :walking
        if holding_any? *@keys_left
          if holding_any? *@keys_up
            # NW
            @avatar.move(315)
          elsif holding_any? *@keys_down
            # SW
            @avatar.move(225)
          else
            # W
            @avatar.move(270)
          end
        elsif holding_any? *@keys_right
          if holding_any? *@keys_up
            # NE
            @avatar.move(45)
          elsif holding_any? *@keys_down
            # SE
            @avatar.move(135)
          else
            # E
            @avatar.move(90)
          end
        elsif holding_any? *@keys_up
          # N
          @avatar.move(0)
        elsif holding_any? *@keys_down
          # S
          @avatar.move(180)
        else
          @avatar.set_body_velocity(0, 0)
          # Standing entirely still.
        end
    end
  end

  def draw
    return unless avatar

    @font.draw "F: #{favor.to_i} H: #{@avatar.health.to_i}", *@gui_pos, ZOrder::GUI, 1, 1, STATUS_COLOR
  end
end
end