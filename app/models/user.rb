class User < ApplicationRecord
  include Rails.application.routes.url_helpers

  rolify

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :lockable, :trackable
  # :timeoutable

  include PgSearch::Model
  pg_search_scope :search, against: [:id, :first_name, :last_name, :email]

  multisearchable against: [:id, :first_name, :last_name, :email]

  has_many :posts, dependent: :nullify

  def full_name
    [first_name, last_name].filter_map(&:presence).join(" ").presence || email
  end

  def short_name
    [first_name&.first, last_name].filter_map(&:presence).join(". ").presence || email
  end

  memoize def initials
    full_name.gsub(/[^\p{L} ]/, "").split.tap { |a| break a.size > 1 ? a[0][0] + a[1][0] : a[0][0..1] }
  end

  def searchable_name
    full_name
  end

  def avatar_color
    (full_name.gsub(/[^a-zA-Z]/, "").to_i(36) % 8) + 1
  end

  alias rolify_has_role? has_role?

  # rubocop:disable Naming/PredicatePrefix
  def has_role?(role, resource=nil)
    roles.any? { |r| r.name.to_sym == role.to_sym && r.resource == resource } ||
      roles.any? { |r| r.name.to_sym == :superadmin }
  end
  # rubocop:enable Naming/PredicatePrefix
  Role::ROLES.each do |role|
    define_method(:"#{role}?") do
      has_role?(role)
    end
  end

  def to_liquid
    attributes.with_indifferent_access
              .slice(:id, :email, :unconfirmed_email, :first_name, :last_name, :job, :company)
              .merge({
                "self_url"  => url_for([:profile, { id: }]),
                "self_path" => url_for([:profile, { id:, only_path: true }])
              })
  end
end
