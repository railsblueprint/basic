module Users
  class CreateCommand < Crud::CreateCommand
    include Attributes

    def resource_attributes
      super.merge(password: SecureRandom.hex(64))
    end
  end
end
