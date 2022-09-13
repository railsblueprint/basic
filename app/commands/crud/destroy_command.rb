module Crud
  class DestroyCommand < BaseCommand
    attribute :id, Types::String

    validates :id, :resource, presence: true

    attribute :current_user, Types::Nominal(User)

    def process
      destroy_resource
    end

    def destroy_resource
      resource.destroy || (errors.copy!(resource.errors) && abort_command)
    end

    memoize def resource
      adapter.find_by(id:)
    end

    def authorized?
      return true if resource.nil?

      Pundit.policy!(current_user, resource).destroy?
    end

    def broadcast_ok
      broadcast :ok, resource
    end
  end
end
