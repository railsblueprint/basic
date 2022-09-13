class Admin::DesignSystemController < Admin::Controller
  def colors
    breadcrumb t("admin.nav.design_system.design_system"), ""
    breadcrumb t("admin.nav.design_system.color_system"), url_for
  end
end
