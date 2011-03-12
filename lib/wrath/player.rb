# encoding: utf-8

# A player that controls a creature in the game.
class Player < BasicGameObject
  extend Forwardable
  include Helpers::InputClient

  STATUS_COLOR = Color.rgba(255, 255, 255, 150)

  KEYS_CONFIG_FILE = File.join(ROOT_PATH, 'config', 'keys.yml')

  INITIAL_FAVOR = 0
  FAVOR_TO_WIN = 100

  def_delegators :@avatar, :alive?, :dead?

  attr_reader :number, :avatar, :favor, :visible

  def local?; true; end # TODO: fix.

  def initialize(number, avatar, options = {})
    options = {
    }.merge! options

    @number = number
    self.avatar = avatar
    @favor = INITIAL_FAVOR

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

    on_input(@keys_action) { @avatar.action } if local?
  end

  def avatar=(creature)
    @avatar.player = nil if @avatar
    @avatar = creature
    @avatar.player = self
  end

  def favor=(value)
    @favor = [[value, 0].max, FAVOR_TO_WIN].min
    parent.win!(self) if @favor == FAVOR_TO_WIN and not parent.winner

    @favor
  end

  def opponent
    (parent.players - [self]).first
  end

  def update
    move_by_keys if local? and alive?
    super
  end

  def move_by_keys
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
      @avatar.
          move(180)
    else
      @avatar.set_body_velocity(0, 0)
      # Standing entirely still.
    end
  end

  def draw
    @font.draw "F: #{favor.to_i} H: #{@avatar.health.to_i}", *@gui_pos, ZOrder::GUI, 1, 1, STATUS_COLOR
  end
end