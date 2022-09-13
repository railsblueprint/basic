# Allows to stub command execution and broadcast given response
# Usage :
#
# stub_command("CommandClass", :ok, 123) - will broadcast :ok, 123 when command is called
#
# stub_command("CommandClass", :invalid) do |errors|
#   errors.add(:base, :invalid)
# end
# - will broadcast :invalid, errors, where :invalid error will added to :base attribute

def stub_command(klass, event_to_publish, *published_event_args, &block)
  stub_const(klass, Class.new(BaseCommand) do
    define_method(:call) do |*_args|
      yield(errors) if block
      if published_event_args.any?
        publish(event_to_publish, *published_event_args)
      else
        publish(event_to_publish, errors)
      end
    end

    # stub all methods
    def self.method_missing(...); end

    def self.respond_to_missing?(...)
      true
    end

    def method_missing(...); end

    def respond_to_missing?(...)
      true
    end
  end)
end
