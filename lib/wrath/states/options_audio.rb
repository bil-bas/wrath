module Wrath
  class OptionsAudio < Gui
    include ShownOverNetworked

    SLIDER_OPTIONS = { width: 75, height: 6, groove_thickness: 2, align_v: :center, range: 0.0..1.0 }

    def body
      grid num_columns: 4, padding: 0 do
        # MASTER
        label t.label.master
        @master_slider = slider SLIDER_OPTIONS do |sender, value|
          $window.volume = value
          settings[:audio, :master_volume] = value
          @master_percentage.text = "#{(value * 100).round}%"
        end
        @master_percentage = label "100%"
        @master_slider.value = $window.volume
        @mute_button = toggle_button(t.button.mute.text, value: $window.muted?, shortcut: :auto, width: 35) do |sender, value|
          if value
            $window.mute
          else
            $window.unmute
          end
          settings[:audio, :muted] = value
        end

        # EFFECTS
        label t.label.effects
        @effects_slider = slider SLIDER_OPTIONS do |sender, value|
          Sample.volume = value
          settings[:audio, :effects_volume] = value
          @effects_percentage.text = "#{(value * 100).round}%"
        end
        @effects_percentage = label "100%"
        @effects_slider.value = Sample.volume

        button(t.button.play_sample.text, width: 35) { Sample["objects/explosion.ogg"].play }

        # MUSIC
        label t.label.music
        @music_slider = slider SLIDER_OPTIONS do |sender, value|
          Song.volume = value
          settings[:audio, :music_volume] = value
          @music_percentage.text = "#{(value * 100).round}%"
        end
        @music_percentage = label "100%"
        @music_slider.value = Song.volume

        #@song = Song["Simply dance - Libra @4_00.ogg"]

        #@play_song_button = button(t.button.play_song.text) { @song.playing? ? @song.stop : @song.play }
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
      #@play_song_button.text = @song.playing? ? "Stop" : "Play"
    end

    def pushed
      log.info { "Started editing audio settings" }
    end

    def popped
      log.info { "Stopped editing audio settings" }
      #@song.stop
    end
  end
end