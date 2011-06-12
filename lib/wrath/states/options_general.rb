module Wrath
  class OptionsGeneral < Gui
    include ShownOverNetworked

    def body
      horizontal padding: 0 do
        label t.label.locale
        @locale_combo = combo_box value: settings[:locale], width: 120, align: :center do
          default = R18n::Locale.load(R18n::I18n.system_locale).title
          item "#{t.default_locale} (#{default})", ''

          R18n.get.available_locales.each do |locale|
            unless locale.supported?
              locale_class_name = locale.code.split('-').map {|s| s.capitalize }.join.to_sym
              locale = R18n::Locales.const_get(locale_class_name).new
            end
            item locale.title, locale.code
          end

          subscribe :changed do |sender, locale|
            settings[:locale] = locale

            $window.options_changed
          end
        end
      end
    end
  end
end