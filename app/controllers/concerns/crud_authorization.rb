module CrudAuthorization
  extend ActiveSupport::Concern
  include Pundit::Authorization
  include ApplicationHelper

  included do
    rescue_from Pundit::NotAuthorizedError do
      message = if request.get?
                  "You are not authorized to view this page."
                else
                  "You are not authorized to perform this action."
                end

      path = admin? ? admin_root_path : root_path
      redirect_to path, error: message
    end

    # rubocop:disable Rails/LexicallyScopedActionFilter
    before_action :authorize_model, only: [:index, :new, :create]
    # rubocop:enable Rails/LexicallyScopedActionFilter

    before_action :authorize_resource, if: lambda { |controller|
                                             controller.action_name.to_sym.in?(controller.actions_with_resource)
                                           }

    def authorize_model
      authorize model
    end

    def authorize_resource
      authorize @resource
    end
  end
end
