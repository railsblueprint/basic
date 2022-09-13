class Admin::SettingsController < Admin::CrudController
  include Breadcrumbs

  def prepend_breadcrumbs
    breadcrumb t("admin.nav.configuration"), ""
    @sets = Setting.where(type: :set)
  end

  def name_attribute
    :description
  end

  def index
    super
    @unsaved = Setting.unsaved.any? if Rails.env.development?
  end

  def no_show_action? = true

  def mass_update
    Settings::MassUpdateCommand.call(settings: params.permit![:settings].to_h, current_user:) do |command|
      command.on(:ok) do
        redirect_to url_for(action: :index), status: :see_other, success: t("messages.successfully_updated")
      end
      command.on(:invalid, :abort) do |errors|
        redirect_to url_for(action: :index), status: :see_other, error: errors.full_messages.to_sentence
      end
    end
  end
end
