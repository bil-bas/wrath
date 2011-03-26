module Wrath
class Menu < Gui
  def initialize
    super

    add_inputs(
        p: :local_game,
        j: :join_game,
        h: :host_game,
        e: :close,
        escape: :close
    )

    Log.level = settings[:debug_mode] ? Logger::DEBUG : Logger::INFO

    create_background

    priest_sprite_files = Play::PRIEST_SPRITES.values.map {|f| File.join('players', f) }
    icons = priest_sprite_files.map {|f| ScaledImage.new(SpriteSheet.new(f, 8, 8)[0], $window.sprite_scale * 3) }

    pack :horizontal do
      pack :vertical, padding_top: 12, spacing: 14 do
        icons[0..3].each {|icon| label '', icon: icon }
      end

      pack :vertical, spacing: 18 do
        heading = label "Wrath!", font_size: 135, color: Color.rgb(30, 100, 255)

        pack :vertical, spacing: 12 do
          width = $window.width / 2

          options = { width: heading.width - 15, font_size: 36, justify: :center }
          button("Play", options.merge(tip: 'Both players on the same keyboard')) { local_game }
          button("Join Game", options.merge(tip: 'Connect to a network game someone else is hosting')) { join_game }
          button("Host Game", options.merge(tip: 'Host a network game that that another player can join')) { host_game }
          button("Options", options.merge(enabled: false))
          button("Exit", options) { close }
        end
      end

      pack :vertical, padding_top: 12, spacing: 14 do
        icons[4..7].each {|icon| label '', icon: icon }
      end
    end
  end

  def create_background
    @background_image = TexPlay.create_image($window, $window.retro_width, $window.retro_height, color: Color.rgb(0, 0, 40))
    500.times do
      @background_image.set_pixel(rand($window.retro_width), rand($window.retro_height),
                                  color: Color.rgba(255, 255, 255, 150 + rand(50)))
    end
  end

  def draw
    @background_image.draw 0, 0, 0
    super
  end

  def setup
    super
    log.info "Viewing main menu"
  end

  def local_game
    push_game_state Lobby.new(nil, "Player2",  "Player1")
  end

  def join_game
    push_game_state JoinDetails
  end

  def host_game
    push_game_state HostDetails
  end

  def close
    log.info "Exited game"
    super
    exit
  end
end
end
