class SettingPolicy < ApplicationPolicy
  def index?
    @user&.superadmin?
  end

  def new?
    return false unless Rails.env.development?
    return false unless @user&.superadmin?
    return false if Setting.disable_settings_editor

    true
  end

  def edit? = new?
  def destroy? = new?

  def mass_update?
    @user&.superadmin? || @user&.admin?
  end
end
