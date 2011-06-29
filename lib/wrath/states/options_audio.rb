module Wrath
  class OptionsAudio < Gui
    include ShownOverNetworked

    SLIDER_OPTIONS = { width: 75, height: 6, groove_thickness: 2, align_v: :center, range: 0.0..1.0 }
    BUTTON_WIDTH = 30

    def body
      grid num_columns: 4, padding: 0 do
        # MASTER
        label t.label.master, align_v: :center
        @master_slider = slider SLIDER_OPTIONS do |sender, value|
          $window.volume = value
          settings[:audio, :master_volume] = value
          @master_percentage.text = "#{(value * 100).round}%"
        end
        @master_percentage = label "100%", align_v: :center
        @master_slider.value = $window.volume
        @mute_button = toggle_button(t.button.mute.text, value: $window.muted?, shortcut: :auto, width: BUTTON_WIDTH) do |sender, value|
          if value
            $window.mute
          else
            $window.unmute
          end
          settings[:audio, :muted] = value
        end

        # EFFECTS
        label t.label.effects, align_v: :center
        @effects_slider = slider SLIDER_OPTIONS do |sender, value|
          Sample.volume = value
          settings[:audio, :effects_volume] = value
          @effects_percentage.text = "#{(value * 100).round}%"
        end
        @effects_percentage = label "100%", align_v: :center
        @effects_slider.value = Sample.volume

        button(t.button.play_sample.text, width: BUTTON_WIDTH) { Sample["objects/explosion.ogg"].play }

        # MUSIC
        label t.label.music, align_v: :center
        @music_slider = slider SLIDER_OPTIONS do |sender, value|
          Song.volume = value
          settings[:audio, :music_volume] = value
          @music_percentage.text = "#{(value * 100).round}%"
        end
        @music_percentage = label "100%", align_v: :center
        @music_slider.value = Song.volume

        @music = Song[Menu::TITLE_MUSIC]

        @play_music_button = button(t.button.play_song.text, width: BUTTON_WIDTH) { @music.playing? ? @music.pause : @music.play(true) }
      end
    end

    def extra_buttons
      button(t.button.default.text, tip: t.button.default.tip) do
        message(t.dialog.confirm_default.message, type: :ok_cancel) do |result|
          if result == :ok
            @master_slider.value = 0.5
            @effects_slider.value = 1.0
            @music_slider.value = 1.0
            @mute_button.value = false
          end
        end
      end
    end

    def update
      super
      @play_music_button.text = @music.playing? ? t.button.stop_song.text : t.button.play_song.text
    end

    def pushed
      log.info { "Started editing audio settings" }
    end

    def popped
      log.info { "Stopped editing audio settings" }
      @music.pause
    end
  end
end