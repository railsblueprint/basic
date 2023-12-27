require "erb"
require "yaml"

module AppConfig
  class YAMLBackend
    def initialize(path="config/app.yml")
      @path = path
    end

    def get(key)
      options[key]
    end

    def init
      require "yaml"
      if File.exist?(path)
        template = ERB.new(File.read(path))
        @options = {}
        # double processing allows to use aliases of form <%= AppConfig.key %>, which are loaded on first pass
        @options = ::YAML.load(template.result(binding), aliases: true)[Econfig.env]
        @options = ::YAML.load(template.result(binding), aliases: true)[Econfig.env]
      else
        @options = {}
      end
    end

    private

    def path
      File.expand_path(@path, Econfig.root)
    end

    def options
      @options or raise Econfig::UninitializedError
    end
  end
end
