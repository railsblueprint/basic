class Admin::DesignSystem::FormsController < Admin::Controller
  before_action do
    breadcrumb t("admin.nav.design_system.design_system"), ""
    breadcrumb t("admin.nav.design_system.forms"), ""
    breadcrumb t("admin.nav.design_system.form_#{params[:action]}"), url_for
  end
end
