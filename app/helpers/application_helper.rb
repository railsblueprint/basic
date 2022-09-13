module ApplicationHelper
  include Pagy::Frontend

  def admin?
    request.original_fullpath.start_with?("/admin")
  end

  def body_class
    "controller-#{params[:controller].tr('/', '-')} action-#{params[:action]}"
  end

  def component(name, *, **, &)
    component = "#{name.to_s.camelize}Component".constantize
    render(component.new(*, **), &)
  end

  def component_to_string(name, *, **, &)
    component = "#{name.to_s.camelize}Component".constantize
    render_to_string(component.new(*, **), &)
  end

  def render_turbo_flash
    return unless turbo_frame_request?

    turbo_stream_action_tag("replace", target: "flash", template: component(:toastr_flash))
  end

  # rubocop:todo Rails/OutputSafety
  def paginator collection
    raw <<~PAGINATOR
      <div class="paginator">
        <nav class="">
          <ul class="pagination">
            <li class="page-item disabled">
              <span class="page-link">
                #{page_entries_info collection}
              </span>
            </li>
          </ul>
        </nav>
        #{paginate collection, theme: 'bootstrap-5'}
      </div>
    PAGINATOR
  end
  # rubocop:enable Rails/OutputSafety
end
