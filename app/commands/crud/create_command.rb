module Crud
  class CreateCommand < BaseCommand
    attribute :current_user, Types::Nominal(User)

    def process
      create_resource
    end

    def create_resource
      @resource = adapter.create(resource_attributes)

      return if @resource.persisted?

      errors.copy!(@resource.errors)

      abort_command
    end

    def resource_attributes
      attributes.without(:current_user, :id)
    end

    def authorized?
      Pundit.policy!(current_user, adapter).create?
    end

    def broadcast_ok
      broadcast :ok, @resource
    end
  end
end
