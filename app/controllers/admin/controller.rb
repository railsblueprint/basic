class Admin::Controller < ApplicationController
  include FormsHelper

  before_action :authenticate_user!
  before_action :check_admin_role

  use_layout "admin"

  before_action do
    @page_title = t(".page_title")
    icon = "<i class=\"bi bi-house-fill \"></i>"
    breadcrumb icon + t("admin.nav.home"), :root_path
    breadcrumb t("admin.nav.admin"), :admin_root_path
  end

  private

  def check_admin_role
    return if current_user.admin?

    flash[:error] = t("common.no_access_to_page")
    redirect_to "/"
  end
end
