class Admin::UsersController < Admin::CrudController
  def actions_with_resource
    super + [:cancel_email_change, :resend_confirmation_email, :update_password]
  end

  # rubocop:disable Metrics/AbcSize, Style/GuardClause
  def filter_resources
    @resources = @resources.with_role(params[:role]) if params[:role].present? && (params[:role][0] != "_")
    if params[:q].present?
      @resources = @resources.where("first_name ilike :q or last_name ilike :q " \
                                    "or email ilike :q or users.id::text = :id", q: "%#{params[:q]}%", id: params[:q])
    end
  end
  # rubocop:enable Metrics/AbcSize, Style/GuardClause

  def lookup
    @resources = model.where("first_name ilike :q or last_name ilike :q",
                             q: "%#{params[:q]}%").order("first_name, last_name").page(params[:page])
    render json: {
      results:    @resources.map { |r| { id: r.id, text: r.full_name } },
      pagination: {
        more: @resources.next_page.present?
      }
    }
  end

  def scope
    super.includes(:roles)
  end

  def name_attribute
    :full_name
  end

  def cancel_email_change
    @resource.update!(unconfirmed_email: nil)
    redirect_to url_for({ action: :edit }), success: t("messages.email_change_cancelled")
  end

  def resend_confirmation_email
    @resource.send_confirmation_instructions
    redirect_to url_for({ action: :edit }),
                success: t("messages.confirmationl_resent", email: @resource.unconfirmed_email)
  end

  def update_password
    Users::UpdatePasswordCommand.call_for(params, context) do |command|
      command.on(:ok) { handle_password_update_success }
      command.on(:invalid, :abort) { |errors| handle_password_update_failure(errors) }
      command.on(:unauthorized) { handle_password_update_unauthorized }
    end
  end

  private

  def handle_password_update_success
    flash[:success] = t("messages.password_changed")
    redirect_to url_for({ action: :edit })
  end

  def handle_password_update_failure(errors)
    @command = update_command.build_from_object_and_attributes(@resource, context)
    flash.now[:error] = {
      message: t("messages.password_change_failed"),
      details: errors.full_messages
    }
    render :edit, status: :unprocessable_entity
  end

  def handle_password_update_unauthorized
    flash[:error] = t("messages.unauthorized")
    redirect_to({ action: :index })
  end
end
