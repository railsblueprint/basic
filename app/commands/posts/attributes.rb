module Posts
  module Attributes
    extend ActiveSupport::Concern
    include Crud::Attributes

    included do
      attribute :title, Types::String
      attribute :user_id, Types::String
      attribute :body, Types::String | Types::Nominal(ActionText::RichText)

      validates :title, :body, presence: true
    end
  end
end
