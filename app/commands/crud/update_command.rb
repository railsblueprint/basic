module Crud
  class UpdateCommand < BaseCommand
    include BuildFromObject

    attribute :id, Types::String

    validates :id, :resource, presence: true

    attribute :current_user, Types::Nominal(User)

    def process
      update_resource
    end

    def update_resource
      return if resource.update(resource_attributes)

      errors.copy!(resource.errors)
      abort_command
    end

    def resource_attributes
      attributes.without(:current_user, :id)
    end

    memoize def resource
      adapter.find_by(id:)
    end

    def broadcast_ok
      broadcast :ok, resource
    end

    def authorized?
      return true if resource.nil?

      Pundit.policy!(current_user, resource).update?
    end

    def persisted?
      true
    end
  end
end
