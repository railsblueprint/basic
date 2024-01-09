module Settings
  class CreateCommand < Crud::CreateCommand
    include Attributes

    def resource_attributes
      attributes.without(:current_user, :id).merge(not_migrated: Rails.env.development?)
    end
  end
end
