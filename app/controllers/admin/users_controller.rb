class Admin::UsersController < Admin::CrudController
  def actions_with_resource
    super + [:cancel_email_change, :resend_confirmation_email]
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
end
