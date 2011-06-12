module Gosu
  class Window
  %w(update draw needs_redraw? needs_cursor?
     lose_focus button_down button_up).each do |callback|
    define_method "protected_#{callback}" do |*args|
      begin
        # Turn into a boolean result for needs_cursor? etc while we are at it.
        @_exception ? false : !!send(callback, *args)
      rescue Exception => e
        # Exit the message loop naturally, then re-throw
        @_exception = e
        close
      end
    end
  end
  end
end