class Admin::Controller < ApplicationController
  before_action :authenticate_user!
  before_action :check_admin_role
  # before_action :check_permissions

  layout "admin"

  before_action do
    @page_title = t(".page_title")
    breadcrumb "<i class='bi bi-house-fill'></i>Home", :root_path
    breadcrumb "Admin", :admin_root_path
  end

  private

  def check_admin_role
    return if current_user.has_role?(:admin)

    flash[:error] = "You cannot access this page"
    redirect_to "/"
  end
end
