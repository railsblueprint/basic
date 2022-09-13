module Breadcrumbs
  extend ActiveSupport::Concern

  included do # rubocop:disable Metrics/BlockLength
    helper_method :search_url

    # rubocop:disable Rails/LexicallyScopedActionFilter
    before_action :update_search_url, only: [:index]
    # rubocop:enable Rails/LexicallyScopedActionFilter

    before_action :prepend_breadcrumbs
    before_action :set_index_breadcrumbs
    before_action :set_search_breadcrumb
    before_action :set_resource_breadcrumbs, if: lambda { |controller|
      controller.action_name.to_sym.in?(controller.actions_with_resource)
    }
    # rubocop:disable Rails/LexicallyScopedActionFilter
    before_action :set_edit_breadcrumbs, only: [:edit, :update]
    before_action :set_create_breadcrumbs, only: [:new, :create]
    # rubocop:enable Rails/LexicallyScopedActionFilter

    # Use to add parent level breadcrumbs
    def prepend_breadcrumbs; end

    def set_index_breadcrumbs
      breadcrumb index_title, index_url
    end

    def set_search_breadcrumb
      breadcrumb("Search results", search_url) if search_url && url_for(index_url) != search_url
    end

    def set_resource_breadcrumbs
      breadcrumb @resource.send(name_attribute), no_show_action? ? "" : { action: :show }
    end

    def set_edit_breadcrumbs
      breadcrumb t("actions.edit"), { action: :edit }
    end

    def set_create_breadcrumbs
      breadcrumb t("actions.new"), { action: :new }
    end

    def index_title
      I18n.t("admin.nav.#{module_name.underscore}")
    end

    def index_url
      url_for action: :index
    rescue ActionController::UrlGenerationError
      ""
    end

    def after_destroy_path
      search_url || index_url
    end

    def update_search_url
      search_options = request.query_parameters.compact_blank
      session[search_url_key] = url_for(**search_options, page: nil)
    end

    def search_url
      session[search_url_key]
    end

    def search_url_key
      :"#{params[:controller]}_search_url"
    end
  end
end
