module Settings
  module Attributes
    extend ActiveSupport::Concern
    include Crud::Attributes
    include UniquenessValidator

    included do
      attribute :key, Types::String
      attribute :type, Types::String
      attribute :description, Types::String
      attribute :value, Types::String
      attribute :section, Types::String

      validates :key, :type, :description, presence: true
      validates :key, uniqueness: true
      validates :section, presence: true, unless: -> { type == "section" }
    end
  end
end
