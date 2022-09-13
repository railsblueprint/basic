module Users
  class ChangePasswordCommand < BaseCommand
    attribute :current_user, Types::Nominal(User)
    attribute :user, Types::Nominal(User)

    attribute :current_password, Types::String
    attribute :password, Types::String
    attribute :password_confirmation, Types::String

    validates_presence_of :user, :password, :password_confirmation, :current_password
    validate :current_password_valid
    validate :password_match

    def process
      user.update(password:, password_confirmation:)
      return if user.valid?

      errors.copy! user.errors
      abort_command
    end

    def current_password_valid
      return if user.nil?
      return if user&.valid_password?(current_password)

      errors.add(:current_password, :invalid, message: "does not match current password")
    end

    def password_match
      return if password == password_confirmation

      errors.add(:password_confirmation, :invalid, message: "does not match new password")
    end

    def authorized?
      return false if user.nil?

      Pundit.policy!(current_user, user).change_password?
    end
  end
end
