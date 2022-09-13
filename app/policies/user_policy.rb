class UserPolicy < ApplicationPolicy
  def change_password?
    @user == @resource || @user&.superadmin?
  end

  def edit?
    @user == @resource || @user&.admin? || @user&.superadmin?
  end

  def change_roles?
    @user&.superadmin?
  end
end
