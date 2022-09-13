class UsersController < ApplicationController
  before_action :load_resource, only: [:edit, :update, :password, :cancel_email_change, :resend_confirmation_email]
  def show
    @resource = params[:id].present? ? User.find(params[:id]) : current_user
    render_404 unless @resource
  end

  def edit
    @command = Users::UpdateCommand.build_from_object(current_user)
    @password_command = Users::ChangePasswordCommand.new
    render :form
  end

  # rubocop:disable Metrics/AbcSize
  # TODO: how i can fix it?
  def update
    Users::UpdateCommand.call_for(params, { id: current_user.id, current_user: }) do |command|
      command.on(:ok) do |_item|
        redirect_to "/profile", success: I18n.t("messages.profile_updated"), turbo_breakout: true
      end
      command.on(:invalid, :abort) do |errors|
        @command = command
        @password_command = Users::ChangePasswordCommand.new
        flash.now[:error] = errors[:base].to_sentence.presence || I18n.t("messages.failed_to_update_profile")
        render "form", status: :unprocessable_entity
      end
      command.on(:unauthorized) do
        redirect_to "/", error: I18n.t("admin.common.item_update_unauthorized"), turbo_breakout: true
      end
    end
  end

  def password
    Users::ChangePasswordCommand.call_for(params, { user: current_user, current_user: }) do |command|
      command.on :ok do
        bypass_sign_in current_user
        redirect_to "/profile", success: I18n.t("messages.password_changed"), turbo_breakout: true
      end
      command.on :invalid, :abort do |_errors|
        @password_command = command
        @command = Users::UpdateCommand.build_from_object(current_user)

        flash.now[:error] = I18n.t("messages.failed_to_update_password")
        render "form", status: :unprocessable_entity
      end
    end
  end
  # rubocop:enable Metrics/AbcSize

  def load_resource
    @resource = current_user

    return if @resource.present?

    redirect_to "/users/login", notice: I18n.t("messages.you_must_be_signed_in_to_edit_your_profile")
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
