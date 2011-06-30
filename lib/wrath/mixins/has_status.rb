module Wrath
  module HasStatus
    def self.included(base)
      base.event :on_applied_status # [self, Status]
      base.event :on_removed_status # [self, Status]
    end

    @@status_types = {}

    # For each status, add a query method.
    # E.g. If there is a Wrath::Status::Poisoned class, there will be a poisoned? method.
    Status.constants.each do |status|
      klass = Status.const_get(status)
      if klass.is_a? Class and klass.ancestors.include? Status
        type = klass.type
        @@status_types[type] = klass
        define_method("#{type}?") do
          not status(type).nil?
        end
      end
    end

    def statuses; @statuses.values; end
    def valid_status?(type); @@status_types.has_key? type; end

    def initialize(*args)
      @statuses = {}
      super(*args)
    end

    # Get the status of this type, if any.
    def status(type)
      @statuses[type]
    end

    def apply_status(type, options = {})
      options = {
          duration: Float::INFINITY,
      }.merge! options

      existing_status = status(type)
      if existing_status
        existing_status.reapply(options)
      else
        status = @@status_types[type].new(self, options.merge(parent: parent))
        parent.send_message(Message::ApplyStatus.new(self, status)) if status.network_apply? and parent and parent.host?

        @statuses[type] = status

        publish :on_applied_status, status
      end
    end

    def remove_status(type)
      return unless status(type)

      status = @statuses.delete type
      parent.send_message(Message::RemoveStatus.new(self, status)) if status.network_remove? and parent and parent.host?
      status.remove

      publish :on_removed_status, status
    end

    def update
      @statuses.each_value do |status|
        status.update_trait if exists? and status.owner == self
        status.update if exists? and status.owner == self
      end

      super
    end

    def draw
      super
      @statuses.each_value(&:draw)
    end
  end
end