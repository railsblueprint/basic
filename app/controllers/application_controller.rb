class ApplicationController < ActionController::Base
  include Pundit::Authorization
  include DevisePatches
  include Pagy::Backend
  include TurboMethods

  before_action :enable_rollbar_link

  etag { current_user&.id }

  add_flash_types :success, :info, :error

  rescue_from Pundit::NotAuthorizedError do
    message = if request.get?
                I18n.t("messages.you_cannot_access_this_page")
              else
                I18n.t("messages.you_cannot_peform_this_action")
              end
    redirect_to root_path, error: message
  end

  use_layout "application"

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
