module CrudBase # rubocop:disable Metrics/ModuleLength
  extend ActiveSupport::Concern

  included do # rubocop:disable Metrics/BlockLength
    helper_method :model, :filters

    before_action :load_resource, if: lambda { |controller|
      controller.action_name.to_sym.in?(controller.actions_with_resource)
    }

    def base_actions_with_resource
      [:show, :edit, :update, :destroy]
    end

    alias_method :actions_with_resource, :base_actions_with_resource

    def index
      load_resources
      order_resources

      @pagy, @resources = paginate(@resources) if respond_to?(:paginate)
    end

    def show; end

    def new
      @command = create_command.new(context)
    end

    def edit
      @command = update_command.build_from_object_and_attributes(@resource, context)
    end

    # rubocop:disable Metrics/AbcSize
    def update
      update_command.call_for(params, context) do |command|
        command.on(:ok) do |resource|
          after_update(resource)
          flash[:success] = I18n.t("admin.common.successfully_updated", record: model.model_name)
          redirect_to after_update_path(resource)
        end
        command.on(:invalid, :abort) do |errors|
          @command = command
          flash.now[:error] = {
            message: I18n.t("admin.common.failed_to_update_item", record: model.model_name),
            details: errors.full_messages
          }
          render :edit, status: :unprocessable_entity
        end
        command.on(:unauthorized) do
          flash[:error] = I18n.t("admin.common.item_update_unauthorized", record: model.model_name)
          redirect_to({ action: :index })
        end
      end
    end

    def create
      create_command.call_for(params, context) do |command|
        command.on(:ok) do |resource|
          after_create(resource)
          flash[:success] = I18n.t("admin.common.successfully_created", record: model.model_name)
          redirect_to after_create_path(resource)
        end
        command.on(:invalid, :abort) do |errors|
          @command = command
          flash.now[:error] = {
            message: I18n.t("admin.common.failed_to_create_item", record: model.model_name),
            details: errors.full_messages
          }

          render :new, status: :unprocessable_entity
        end
        command.on(:unauthorized) do
          flash[:error] = I18n.t("admin.common.item_create_unauthorized", record: model.model_name)
          redirect_to({ action: :index })
        end
      end
    end

    def destroy
      destroy_command.call_for(params, context) do |command|
        command.on(:ok) do |resource|
          after_destroy(resource)
          flash[:notice] = I18n.t("admin.common.item_deleted_ok", record: model.model_name)
          redirect_to after_destroy_success_path
        end
        command.on(:invalid, :abort) do |errors|
          flash[:error] = {
            message: I18n.t("admin.common.failed_to_delete_item", record: model.model_name),
            details: errors.full_messages
          }
          redirect_to after_destroy_fail_path
        end
        command.on(:unauthorized) do
          flash[:error] = I18n.t("admin.common.item_delete_unauthorized", record: model.model_name)
          redirect_to after_destroy_fail_path
        end
      end
    end
    # rubocop:enable Metrics/AbcSize

    private

    def no_show_action? = false

    def load_resources
      if search_class.present?
        @resources = search_class.call_for(params, context)
      else
        @resources = scope
        filter_resources
      end
    end

    def id_attribute
      :id
    end

    def name_attribute
      :name
    end

    def scope
      model.all
    end

    def model
      module_name.singularize.constantize
    end

    def module_name
      self.class.name.gsub(/(^#{namespace}::|Controller$)/, "")
    end

    def module
      module_name.constantize
    end

    def namespace
      self.class.module_parent
    end

    def update_command
      "#{module_name}::UpdateCommand".constantize
    end

    def create_command
      "#{module_name}::CreateCommand".constantize
    end

    def destroy_command
      "#{module_name}::DestroyCommand".constantize
    end

    def search_class
      "#{namespace}::#{module_name}Search".safe_constantize
    end

    def filter_resources
      @resources = @resources.search(params[:q]) if params[:q].present? && @resources.respond_to?(:search)
    end

    def order_resources
      @resources = @resources.order(created_at: :desc)
    end

    def load_resource
      @resource = scope.find(params[:id])
    end

    def params_with_context
      context.merge(all_params)
    end

    def after_create(_resource); end
    def after_update(_resource); end
    def after_destroy(_resource); end

    def after_create_path(item)
      url_for({ action: :edit, id: item.id })
    end

    def after_update_path(_item)
      url_for(action: :edit)
    end

    def after_destroy_path
      url_for(action: :index)
    end

    def after_destroy_success_path
      after_destroy_path
    end

    def after_destroy_fail_path
      after_destroy_path
    end

    def context
      {
        id: @resource&.id
      }
    end
  end
end
