module Wrath
class Menu < Gui
  class WalkingPriest < GameObject
    VELOCITY = 15 / 1000.0 unless defined? VELOCITY
    LEFT_X = 25 unless defined? LEFT_X

    def initialize(name, options = {})
      options = {
          color: Priest.unlocked?(name) ? Color::WHITE : Color::BLACK,
          factor: 3 * 1.125, # So there is a one-pixel overlap.
          rotation_center: :bottom_center,
          x: LEFT_X,
      }.merge! options

      super(options)

      @animation = Priest.animation(name)[0..1]
      @velocity = VELOCITY

      self.image = @animation[0]
    end

    def animate
      self.image = @animation.next
    end

    def reverse_direction
      self.factor_x *= -1
      @velocity *= -1
    end

    def update
      super

      self.y += @velocity * parent.frame_time

      if @velocity > 0 and y > ($window.height + height)
        self.y -= 2 * (y - ($window.height + height))
        self.x = Game::REAL_WIDTH - LEFT_X
        reverse_direction
      elsif @velocity < 0 and y < 0
        self.y *= -1
        self.x = LEFT_X
        reverse_direction
      end

      self.zorder = y
    end
  end

  # -----------------------
  trait :timer

  ACTIONS = {
    play: Play,
    instructions: Instructions,
    achievements: ViewAchievements,
    options: Options,
    exit: :close,
  }

  def initialize
    super
    every(1000.0 / 16) { @priests.each(&:animate) }
  end

  def setup
    super

    Log.level = settings[:debug_mode] ? Logger::DEBUG : Logger::INFO

    @priests = Priest::NAMES.map.with_index do |name, i|
      WalkingPriest.create(name, y: ($window.height * 2) - ((i * $window.height * 2) / (Priest::NAMES.size - 2.0)))
    end

    horizontal spacing: 0, align: :center do
      vertical spacing: 0, padding: 0 do
        label t.title, font_size: 30, color: Color.rgb(50, 120, 255), width: 30, justify: :center, padding_v: 0
        label t.subtitle, font_size: 10, color: Color.rgb(90, 180, 255), align: :center, padding_top: 0, justify: :center
        vertical spacing: 2, align: :center do
          options = { width: 75, justify: :center, shortcut: :auto }
          ACTIONS.each_pair do |name, action|
            button(t.button[name].text, options.merge(tip: t.button[name].tip)) do
              case action
                when Class then push_game_state(action)
                when Symbol then send(action)
              end
            end
          end
        end

        label t.label.version(VERSION), font_size: 4, justify: :center, align: :center
      end
    end

    log.info "Viewing main menu"
  end

  def finalize
    super
    game_objects.each(&:destroy)
  end

  def close
    log.info "Exited game"
    super
    exit
  end
end
end
