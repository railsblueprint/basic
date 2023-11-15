module Posts
  module Attributes
    extend ActiveSupport::Concern

    module Types
      include Dry::Types(default: :params)
    end

    included do
      attribute :title, Types::String
      attribute :user_id, Types::String
      attribute :body, Types::String | Types::Nominal(ActionText::RichText)

      validates :title, :user_id, :body, presence: true
    end
  end
end