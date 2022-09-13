module ToggleBoolean
  extend ActiveSupport::Concern
  include ApplicationHelper

  included do
    def self.toggle_boolean *fields
      fields.each do |field|
        define_method :"toggle_#{field}" do
          toggle_boolean_action(field)
        end
      end
    end
  end

  # rubocop:disable Metrics/AbcSize
  def toggle_boolean_action field
    load_resource

    if policy(@resource).update?
      @resource.update!(field => !@resource.send(field))
      flash.now[:success] = t("admin.common.successfully_updated")
    else
      flash.now[:error] = t("admin.common.not_authorized")
    end

    respond_to do |format|
      format.turbo_stream {
        render turbo_stream: turbo_stream.replace("#{@resource.id}_#{field}", partial: "shared/toggle_bool",
                                                                              locals:  { field: }) +
                             turbo_stream.append("flash_inner", component_to_string(:toastr_flash, append: true))
      }
      format.html { redirect_to(action: :show) }
    end
  end
  # rubocop:enable Metrics/AbcSize
end
