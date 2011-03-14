module Wrath
class Message
  # Action request from the client to the host.
  class RequestAction < Message
    def log_pre; "Failed to process #{self.class.name} -"; end

    def initialize(actor, target = nil)
      @actor_id = actor.id
      @target_id = target ? target.id : nil
      @carrying_id = actor.carrying ? actor.carrying.id : nil
    end

    public
    def process
      actor = object_by_id(@actor_id)
      carrying = @carrying_id ? object_by_id(@carrying_id) : nil
      target = @target_id ? object_by_id(@target_id) : nil

      if actor
        if @carrying_id.nil? or carrying
          # Ensure the actor is still carrying the same object on the host.
          if actor.carrying == carrying
            if @target_id.nil? or target
              if target
                target.activate(actor)
              else
                actor.drop
              end
            else
              log.warn { "#{log_pre} could not find target ##{@target_id}" }
            end
          else
            log.warn { "#{log_pre} actor ##{@actor_id} no longer carrying #{@carrying_id ? "#{carrying.class}##{@carrying_id}" : "nothing"}" }
          end
        else
          log.warn { "#{log_pre} could not find carried ##{@carrying_id}" }
        end
      else
        log.warn { "#{log_pre} could not find actor ##{@actor_id}" }
      end
    end
  end
end
end