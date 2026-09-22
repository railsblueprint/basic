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

  CUTLINE = 'sgid="horizontal-rule"'.freeze

  def transliterated_title
    I18n.transliterate(title, locale: :en)
  end

  def cutline?
    return false if body.blank?
    return false unless rich_text_body.respond_to?(:body_before_type_cast)

    rich_text_body.body_before_type_cast.to_s.include?(CUTLINE)
  end

  def teaser
    return body unless cutline?

    raw_html = rich_text_body.body_before_type_cast.to_s
    cutline_index = raw_html.index(CUTLINE)
    return body unless cutline_index

    opening_tag_index = raw_html[0...cutline_index].rindex("<action-text-attachment")
    return body unless opening_tag_index

    fragment = Nokogiri::HTML::DocumentFragment.parse(raw_html[0...opening_tag_index])
    %(<div class="trix-content">#{fragment.to_html}</div>).html_safe # rubocop:disable Rails/OutputSafety
  end
end
