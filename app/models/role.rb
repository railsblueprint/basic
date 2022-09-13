class Role < ApplicationRecord
  has_and_belongs_to_many :users, join_table: :users_roles

  belongs_to :resource,
             polymorphic: true,
             optional:    true

  validates :resource_type,
            inclusion: { in: Rolify.resource_types },
            allow_nil: true

  scopify

  ROLES = [:moderator, :admin, :superadmin].freeze

  ROLES.map do |role|
    define_singleton_method(role) do
      Role.find_or_create_by(name: role)
    end
  end
end
