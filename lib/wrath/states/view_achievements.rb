module Wrath
  class ProgressBar < Fidgit::Label
    BACKGROUND_COLOR = Color.rgb(150, 150, 150)
    BAR_COLOR = Color.rgb(255, 255, 255)
    TEXT_COLOR = Color.rgb(0, 0, 0)

    def initialize(total, required, options = {})
      options = {
          background_color: BACKGROUND_COLOR,
          color: TEXT_COLOR,
      }.merge! options

      super("#{total} / #{required}", options)

      @progress = [total.to_f / required, 1].min
    end

    def draw_background
      super
      draw_rect(x, y, width * @progress , height, z, BAR_COLOR) if @progress > 0
    end
  end

  class ViewAchievements  < Gui
    ACHIEVEMENT_BACKGROUND_COLOR = Color.rgb(0, 0, 50)
    WINDOW_BACKGROUND_COLOR = Color.rgb(0, 0, 100)

    INCOMPLETE_TITLE_COLOR = Color.rgb(150, 150, 150)
    COMPLETE_TITLE_COLOR = Color.rgb(0, 255, 0)
    UNLOCK_BACKGROUND_COLOR = Color.rgb(50, 50, 50)

    def initialize
      super

      add_inputs(
          c: :pop_game_state,
          escape: :pop_game_state
      )

      pack :vertical do
        label "Achievements", font_size: 32

        scroll_window width: $window.width - 50, height: $window.height - 150, background_color: WINDOW_BACKGROUND_COLOR do
          pack :vertical do
            achievement_manager.achievements.each do |achieve|
              pack :vertical, spacing: 0, background_color: ACHIEVEMENT_BACKGROUND_COLOR do
                pack :horizontal, padding: 0, spacing: 0 do |packer|
                  # title
                  color = achieve.complete? ? COMPLETE_TITLE_COLOR : INCOMPLETE_TITLE_COLOR
                  packer.label achieve.title, width: 400, font_size: 20, color: color

                  # Progress bar, if needed.
                  if achieve.complete?
                    packer.label "Complete!", font_size: 15
                  else
                    ProgressBar.new(achieve.total, achieve.required,
                                    parent: packer, width: 225, height: 20, font_size: 15)
                  end
                end

                # Description of what has been done.
                text_area text: achieve.description, font_size: 15, width: $window.width - 150,
                          background_color: ACHIEVEMENT_BACKGROUND_COLOR, enabled: false

                if achieve.complete? and not achieve.unlocks.empty?
                  pack :horizontal, padding: 0, spacing: 4 do
                    achieve.unlocks.each do |unlock|
                      icon = ScaledImage.new(unlock.image, sprite_scale * 0.75)
                      label "", icon: icon, tip: "Unlocked: #{unlock.title}", background_color: UNLOCK_BACKGROUND_COLOR
                    end
                  end
                end
              end
            end
          end
        end

        pack :horizontal, padding: 0 do
          button("(C)ancel") { pop_game_state }
        end
      end
    end
  end
end