class Admin::DesignSystem::ChartsController < Admin::Controller
  before_action do
    breadcrumb t("admin.nav.design_system.design_system"), ""
    breadcrumb t("admin.nav.design_system.components"), ""
    breadcrumb t("admin.nav.design_system.#{params[:action]}"), url_for
  end
end
