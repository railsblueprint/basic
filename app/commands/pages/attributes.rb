module Pages
  module Attributes
    extend ActiveSupport::Concern
    include Crud::Attributes
    include UniquenessValidator

    included do
      attribute :url, Types::String
      attribute :title, Types::String
      attribute :body, Types::String
      attribute :seo_title, Types::String
      attribute :seo_keywords, Types::String
      attribute :seo_description, Types::String
      attribute :icon, Types::String
      attribute :active, Types::String | Types::Bool
      attribute :show_in_sidebar, Types::String | Types::Bool

      validates :title, presence: true
      validates :url, uniqueness: true
    end
  end
end
