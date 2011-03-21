module Wrath
class Message
  # Action request from the client to the host.
  class RequestAction < Message
    protected
    def log_pre; "Failed to process #{self.class.name} -"; end

    public
    def initialize(actor, target = nil)
      @actor_id = actor.id
      @target_id = target ? target.id : nil
      @contents_id = actor.full? ? actor.contents.id : nil
      log.debug "Sending action"
      log.debug self.inspect
    end

    protected
    def action(state)
      log.debug "Running action"
      log.debug self.inspect

      actor = object_by_id(@actor_id)
      contents = @contents_id ? object_by_id(@contents_id) : nil
      target = @target_id ? object_by_id(@target_id) : nil

      if actor
        if @contents_id.nil? or contents
          # Ensure the actor is still carrying the same object on the host.
          if actor.contents == contents
           activate(actor, target)
          else
            log.warn { "#{log_pre} #{actor.class}##{@actor_id} isn't carrying the expected #{@contents_id ? "#{contents.class}##{@contents_id}" : "nothing"}" }
          end
        else
          log.warn { "#{log_pre} could not find carried ##{@contents_id}" }
        end
      else
        log.warn { "#{log_pre} could not find actor ##{@actor_id}" }
      end
    end

    def activate(actor, target)
      actor.request_action(target)
    end
  end
end
end