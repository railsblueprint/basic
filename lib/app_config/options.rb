module AppConfig

  class Options < ActiveSupport::OrderedOptions
    def initialize(options = {})
      super()
      options.each do |key, value|
        send("#{key}=", value)
      end
    end

    def []=(key, value)
      value = self.class.new(value) if value.is_a?(Hash)
      super(key.to_sym, value)
    end
  end
end