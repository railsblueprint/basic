class ApplicationController < ActionController::Base
  # @page_title       = 'Member Login'
  # @page_description = 'Member login page.'
  # @page_keywords    = 'Site, Login, Members'

  include DevisePatches
  include Pagy::Backend
  before_action :enable_rollbar_link

  rescue_from CanCan::AccessDenied do
    message = if request.method == "GET"
                I18n.t("messages.you_cannot_access_this_page")
              else
                I18n.t("messages.you_cannot_peform_this_action")
              end

    redirect_to root_path, alert: message
  end

  def enable_rollbar_link
    cookies.signed.permanent["show_rollbar_link"] = true if current_user&.has_role?(:superadmin)
  end

  def render_404 # rubocop:disable  Naming/VariableNumber
    raise ActionController::RoutingError.new("Not Found")
  end

  def after_inactive_sign_up_path_for(_resource)
    "/users/login"
  end
end