class PostsController < CrudController
  include CableReady::Broadcaster

  before_action :authenticate_user!, only: [:new, :create, :edit, :update, :destroy], prepend: true
  before_action :turbo_frame_request_variant

  def turbo_frame_request_variant
    request.variant = :turbo_frame if turbo_frame_request?
  end

  def scope
    Post.includes(:user).with_all_rich_text
  end

  def paginate(collection)
    pagy(collection, items: 5)
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
      html:     render_to_string(partial: "post_body", locals: { post: resource })
    ).broadcast_to(resource)
  end
end
