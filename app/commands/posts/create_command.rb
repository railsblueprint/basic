module Posts
  class CreateCommand < Crud::CreateCommand
    include Attributes

    def resource_attributes
      super.merge(user_id:)
    end

    def user_id
      return attributes[:user_id] || current_user.id if Pundit.policy!(current_user, adapter).change_user?

      current_user.id
    end
  end
end
