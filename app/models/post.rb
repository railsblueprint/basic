class Post < ApplicationRecord
  include PgSearch::Model

  pg_search_scope :search, against:            :title,
                           associated_against: {
                             rich_text_body: [:body]
                           }

  multisearchable against: [:id, :title], associated_against: {
    rich_text_body: [:body]
  }

  extend FriendlyId

  friendly_id :transliterated_title, use: :slugged, routes: :id

  belongs_to :user

  has_rich_text :body

  def transliterated_title
    I18n.transliterate(title, locale: :en)
  end
end
