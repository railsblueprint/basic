module Settings
  class DestroyCommand < Crud::DestroyCommand
    def destroy_resource
      if Rails.env.development?
        resource.update!(deleted_at: Time.current)
      else
        resource.destroy || (errors.copy!(resource.errors) && abort_command)
      end
    end
  end
end
