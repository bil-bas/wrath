module Wrath
  class ProgressBar < Fidgit::Label
    BACKGROUND_COLOR = Color.rgb(150, 150, 150)
    BAR_COLOR = Color.rgb(255, 255, 255)
    TEXT_COLOR = Color.rgb(0, 0, 0)

    def initialize(total, required, options = {})
      options = {
          background_color: BACKGROUND_COLOR,
          color: TEXT_COLOR,
          padding_left: 12,
      }.merge! options

      super("#{total.floor} / #{required.floor}", options)

      @progress = [total.to_f / required, 1].min
    end

    def draw_background
      super
      draw_rect(x, y, width * @progress , height, z, BAR_COLOR) if @progress > 0
    end
  end

  class ViewAchievements  < Gui
    ACHIEVEMENT_BACKGROUND_COLOR = Color.rgb(0, 0, 20)

    INCOMPLETE_TITLE_COLOR = Color.rgb(150, 150, 150)
    COMPLETE_TITLE_COLOR = Color.rgb(0, 255, 0)
    UNLOCK_BACKGROUND_COLOR = Color.rgb(50, 50, 50)
    MAX_HUMAN_TIME = 60*60*24*7 # Max time to show human-readable, rather than regular time format.

    trait :timer

    def setup
      super

      # Store the current achievements, so we can add them in #update.
      @completed, incomplete = achievement_manager.achievements.partition {|a| a.complete?}
      @achievements_to_add = @completed + incomplete

      @achieved_time_labels = []

      every(5000) { update_time_labels }

      vertical do
        horizontal padding: 0 do |packer|
          packer.label t.title, font_size: 32
          completed = achievement_manager.achievements.count {|a| a.complete? }
          Wrath::ProgressBar.new(completed, achievement_manager.achievements.size,
                                    parent: packer, width: $window.width - 450, font_size: 32)
        end

        scroll_window width: $window.width - 40, height: $window.height - 150, background_color: BACKGROUND_COLOR do
          # List will be populated in #update.
          @achievements_list = vertical spacing: 5
        end

        horizontal padding: 0 do
          button(t.button.back.text, shortcut: :auto) { pop_game_state }

          toggle_button(t.button.unlock.text, tip: t.button.unlock.tip, value: achievement_manager.unlocks_disabled?) do |sender, value|
            achievement_manager.unlocks_disabled = value
          end

          button t.button.reset.text, tip: t.button.reset.tip do |sender|
            achievement_manager.reset
            switch_game_state self.class
          end
        end
      end
    end

    public
    def update
      # Add a couple of achievements each frame, so we don't freeze up the GUI.
      unless @achievements_to_add.empty?
        @achievements_to_add.shift(1).each {|a| add_achievement(a, @achievements_list) }
        update_time_labels
      end

      super
    end

    protected
    def update_time_labels
      @completed[0...@achieved_time_labels.size].each_with_index do |achieve, i|
        completed_at = achievement_manager.completion_time(achieve.name)
        completed_at = R18n.get.l completed_at, ((Time.now - completed_at) < MAX_HUMAN_TIME) ? :human : nil
        label = @achieved_time_labels[i]
        label.text = completed_at unless label.text == completed_at
      end
    end
    
    protected
    def add_achievement(achieve, packer)
      horizontal parent: packer, padding: 4, spacing: 0, background_color: ACHIEVEMENT_BACKGROUND_COLOR do
        label "", icon: ScaledImage.new(achieve.icon, sprite_scale * 1.5),
            border_thickness: 4, border_color: Color::BLACK, padding: 0

        vertical padding: 0, spacing: 0 do
          horizontal padding: 0, spacing: 0 do |packer|
            # title
            color = achieve.complete? ? COMPLETE_TITLE_COLOR : INCOMPLETE_TITLE_COLOR
            packer.label achieve.title, width: 400, font_size: 20, color: color

            # Progress bar, if needed.
            if achieve.complete?
              @achieved_time_labels << packer.label('', font_size: 15, padding_left: 0)
            else
              ProgressBar.new(achieve.total, achieve.required,
                      parent: packer, width: $window.width - 590, height: 20, font_size: 15)
            end
          end

          # Description of what has been done.
          text_area text: achieve.description, font_size: 15, width: $window.width - 180,
              background_color: ACHIEVEMENT_BACKGROUND_COLOR, enabled: false

          unless achieve.unlocks.empty?
            horizontal padding: 0, spacing: 4 do
              achieve.unlocks.each do |unlock|
                icon = ScaledImage.new(unlock.icon, sprite_scale * 0.75)
                title = unlock.unlocked? ? t.unlocked : t.locked
                label "", icon: icon, tip: "#{title}: #{unlock.title}", background_color: UNLOCK_BACKGROUND_COLOR
              end
            end
          end
        end
      end
    end
  end
end