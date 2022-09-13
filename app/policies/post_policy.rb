class PostPolicy < ApplicationPolicy
  def new?
    user.present?
  end

  def create? = new?

  def edit?
    return false unless user

    resource.user == user || user.moderator? || user.admin? || user.superadmin?
  end

  def update? = edit?
  def destroy? = edit?
end
