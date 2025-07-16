module Users
  class UpdatePasswordCommand < BaseCommand
    attribute :current_user, Types::Nominal(User)
    attribute :id, Types::String

    attribute :password, Types::String
    attribute :password_confirmation, Types::String

    validates_presence_of :id, :password, :password_confirmation
    validates_length_of :password, minimum: 6
    validate :password_match

    def process
      return if resource.update(password:, password_confirmation:)

      errors.copy!(resource.errors)
      abort_command
    end

    def password_match
      return if password == password_confirmation

      errors.add(:password_confirmation, :invalid, message: "does not match password")
    end

    memoize def resource
      User.find_by(id:)
    end

    def authorized?
      return false if resource.nil?

      Pundit.policy!(current_user, resource).change_password?
    end
  end
end
