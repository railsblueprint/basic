class Admin::DashboardController < Admin::Controller
  def show
    breadcrumb t("admin.nav.dashboard"), :admin_root_path
    @page_title = t("admin.nav.dashboard")
  end

  def search
    breadcrumb t("admin.nav.global_search"), url_for
    return if params[:q].blank?

    @results = PgSearch.multisearch(params[:q]).includes(:searchable).page(params[:page])
  end
end
