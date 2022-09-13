module Crud
  module Attributes
    def self.included(parent)
      parent.module_eval do
        const_set :Types, Module.new
      end

      parent::Types.module_eval do
        include Dry::Types(default: :params)
      end
    end
  end
end
