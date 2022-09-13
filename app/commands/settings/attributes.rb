module Settings
  module Attributes
    extend ActiveSupport::Concern
    include Crud::Attributes
    include UniquenessValidator

    included do
      attribute :alias, Types::String
      attribute :type, Types::String
      attribute :description, Types::String
      attribute :value, Types::String
      attribute :set, Types::String

      validates :alias, :type, :description, presence: true
      validates :alias, uniqueness: true
    end
  end
end
