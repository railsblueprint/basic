class MailTemplate < ApplicationRecord
  default_scope -> { where(deleted_at: nil) } if Rails.env.development?

  scope :unsaved, -> { unscoped.where.not(deleted_at: nil).or(MailTemplate.where(not_migrated: true)) }

  scope :search, ->(q) { where("alias like :q or subject like :q ", q: "%#{q}%") }

  def self.available_layouts
    Rails.root.join("app/views/layouts/mail").entries.map(&:to_s).reject { |f|
      f.start_with?(".")
    }.map(&it.split(".").first)
  end
end
