class Admin::PostsController < Admin::CrudController
  include CableReady::Broadcaster

  # rubocop:disable Style/GuardClause
  def filter_resources
    @resources = @resources.search(params[:q]) if params[:q].present?

    if params[:user_id].present?
      @resources = @resources.where(user_id: params[:user_id])
      @selected_user = User.find(params[:user_id])
    end
  end
  # rubocop:enable Style/GuardClause

  def scope
    model.includes(:user)
  end

  def name_attribute
    :title
  end

  def after_create(resource)
    cable_ready[BlogChannel].prepend(
      selector: "#posts",
      html:     render_to_string(partial: "posts/post", locals: { post: resource, no_controls: true })
    ).broadcast_to("blog")
  end

  def after_update(resource)
    cable_ready[PostChannel].morph(
      selector: "#{dom_id(resource)}_body",
      html:     render_to_string(partial: "posts/post_body", locals: { post: resource })
    ).broadcast_to(resource)
  end
end
