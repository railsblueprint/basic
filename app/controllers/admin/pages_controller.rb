class Admin::PagesController < Admin::CrudController
  include ToggleBoolean
  toggle_boolean :active, :show_in_sidebar

  def filter_resources
    @resources = @resources.search(params[:q]) if params[:q].present?
    filter_boolean :active
    filter_boolean :show_in_sidebar
  end

  def name_attribute
    :title
  end
end
