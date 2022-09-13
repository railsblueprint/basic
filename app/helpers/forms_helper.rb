# rubocop:disable Metrics/ModuleLength
# TODO: split into files
module FormsHelper
  def inside_layout(parent_layout, &)
    view_flow.set :layout, capture(&)
    render template: "layouts/#{parent_layout}"
  end

  FLASH_MAP = {
    notice:  "alert-info",
    success: "alert-success",
    error:   "alert-danger",
    alert:   "alert-warning"
  }.freeze

  # rubocop:todo Rails/OutputSafety
  def flash_bootstrap
    raw flash.map { |key, value|
      "<div class='alert alert-dismissible #{FLASH_MAP[key.to_sym]}'  role='alert'>
       #{value}
      <button type='button' class='btn-close' data-bs-dismiss='alert' aria-label='#{t('actions.close')}'></button>
      </div>"
    }.join
  end

  def modal_template
    raw '<div id="modal-window" class="modal fade" tabindex="-1">
          <div class="modal-dialog modal-lg">
            <div id="modal-window-content" class="modal-content">
        </div></div></div>'
  end
  # rubocop:enable Rails/OutputSafety

  # Bootstrap icon helper
  def bi icon, options={}
    content_tag :i, nil, class: "bi bi-#{icon} #{options[:class]}"
  end

  # Bootstrap icon helper - using svg format
  def bi_svg icon, options={}
    content_tag :svg, nil, class: "bi bi-#{icon} #{options}",
                width: "32", height: "32", viewBox: "0 0 20 20",
                fill: "currentColor", xmlns: "http://www.w3.org/2000/svg"
  end

  # Glyphicons icon helpers
  def gi icon, options={}
    content_tag :span, nil, class: "glyphicon glyphicon-#{icon} #{options[:class]}"
  end

  # Fontawsome icon helpers
  def fa icon, options={}
    content_tag :i, nil, class: "fa fa-#{icon} #{options[:class]}"
  end

  def fab icon, options={}
    content_tag :i, nil, class: "fab fa-#{icon} #{options[:class]}"
  end

  def fas icon, options={}
    content_tag :i, nil, class: "fas fa-#{icon} #{options[:class]}"
  end

  def far icon, options={}
    content_tag :i, nil, class: "far fa-#{icon} #{options[:class]}"
  end

  def fal icon, options={}
    content_tag :i, nil, class: "fal fa-#{icon} #{options[:class]}"
  end

  def copy_field_button
    content_tag "button",
                class:             "btn btn-outline-secondary",
                "data-controller": "field-clipboard",
                "data-action":     "field-clipboard#click",
                title:             I18n.t("actions.copy_to_clipboard"),
                "data-success":    I18n.t("messages.copied_successfully"),
                "data-failure":    I18n.t("messages.failed_to_copy") do
      bi "clipboard"
    end
  end

  def link_field_button options={}
    link_to "#", class: "btn btn-outline-secondary",
            title: I18n.t("actions.open_link_in_new_tab"), "data-url-prefix": options[:url_prefix],
            "data-bs-toggle": "tooltip",
            "data-controller": "field-url",
            "data-local": options[:local],
            target: "_blank",
            rel: "noreferrer" do
      bi "link-45deg"
    end
  end

  def filter_by name, options, settings={}
    controller = ["select2 admin--search-filter", settings.dig(:data, :controller)].compact.join(" ")

    select_tag name,
               options_for_select(options, params[name]),
               class: "form-control form-control-sm select2",
               **settings,
               data:  {
                 **settings.fetch(:data, {}),
                 controller:,
                 url:        url_for(**request.query_parameters, name => nil, :page => nil)
               }
  end

  def filter_by_binary name, options=[["Any", nil], ["True", true], ["False", false], %w[Unknown nil]]
    filter_by name, options
  end

  def filter_by_user(options={})
    selected = options.delete(:selected)
    default_option = if selected
                       [[I18n.t("search.any"), nil],
                        [selected.full_name, selected.id]]
                     else
                       [[I18n.t("search.any"), nil]]
                     end

    filter_by :user_id,
              default_option,
              data: {
                source: "/admin/users/lookup",
                empty:  I18n.t("search.any")
              }
  end

  def filter_by_role
    filter_by :role,
              [[I18n.t("search.any"), nil], * Role.all.map { |r| [r.name, r.name] }]
  end

  def filter_by_active
    filter_by_binary :active
  end

  # rubocop:disable Metrics/MethodLength
  # TODO: convert to a constant
  memoize def bool_icons
    {
      nil      => {
        true  => bi("check-lg"),
        false => bi("x-lg")
      },
      :star    => {
        true  => fas("star"),
        false => far("star")
      },
      :heart   => {
        true  => fas("heart"),
        false => far("heart")
      },
      :dislike => {
        true  => fas("thumbs-down"),
        false => fal("thumbs-down")
      },
      :eye     => {
        true  => fas("eye"),
        false => far("eye text-secondary")
      },
      :acorn   => {
        true  => fas("acorn text-success"),
        false => far("acorn text-danger"),
        nil   => fas("acorn text-secondary")
      }
    }
  end
  # rubocop:enable Metrics/MethodLength

  def toggle_bool resource, field, options={}
    if policy(resource).update?
      link_to url_for(action: "toggle_#{field}", id: resource.id), data: { turbo_method: :patch } do
        toggle_bool_icon resource, field, options
      end
    else
      toggle_bool_icon resource, field, options
    end
  end

  def toggle_bool_icon resource, field, options={}
    icon = (resource.respond_to?("#{field}_icon") && resource.send("#{field}_icon")) || options[:icon]
    content_tag :"turbo-frame", id: "#{resource.id}_#{field}" do
      icons = bool_icons[icon] || bool_icons[nil]

      bool_icon(icons, resource.send(field))
    end
  end

  def bool_icon(icons, value)
    if value.nil? && icons[nil].present?
      icons[nil]
    else
      icons[value.to_b]
    end
  end

  def clipboardable(text=nil, &block)
    text ||= capture(&block) if block

    return if text.blank?

    content_tag(:span) do
      content_tag(:span, text, class: "clipboard_data") +
      link_to(nil, class: "copy_to_clipboard", role: "button", title: "Copy to clipboard") do
        fa("copy")
      end
    end
  end

  # rubocop:todo Rails/OutputSafety
  def delete_button(resource, options={})
    return unless policy(resource).destroy?

    url = admin? ? [:admin, resource] : [resource]

    link_to url,
            data:  { turbo_method: :delete,
                     controller: "confirmation", action: "confirmation#click",
                     confirm:      "Are you sure you want to delete this #{resource.class.name}?" },
            class: "btn btn-outline-danger #{'btn-sm' if options[:small]}" do
      "#{bi('trash')} Delete".html_safe
    end
  end

  def edit_button(resource, options={})
    return unless policy(resource).edit?

    css_class = "btn btn-outline-primary #{'btn-sm' if options[:small]} #{'stretched-link' if options[:stretched]}"

    url = admin? ? [:edit, :admin, resource] : [:edit, resource]

    link_to url,
            class:              css_class,
            "data-turbo-frame": "_top" do
      "#{bi('pencil')} #{t('actions.edit')}".html_safe
    end
  end

  def create_button(resource, options={})
    return unless policy(resource).create

    link_to [:new, :admin, resource.to_s.underscore.to_sym],
            class:              "btn btn-primary #{'btn-sm' if options[:small]} " \
                                "#{'stretched-link' if options[:stretched]}",
            "data-turbo-frame": "_top" do
      "#{bi('plus-lg')} #{t('actions.create')}".html_safe
    end
  end

  def view_button(resource, options={})
    return unless policy(resource).show?
    return if options[:fallback_from].present? && policy(resource).send(:"#{options[:fallback_from]}?")

    link_to [:admin, resource],
            class:              "btn btn-outline-primary #{'btn-sm' if options[:small]} " \
                                "#{'stretched-link' if options[:stretched]}",
            "data-turbo-frame": "_top" do
      "#{bi('eye')} #{t('actions.details')}".html_safe
    end
  end
  # rubocop:enable Rails/OutputSafety
end
# rubocop:enable Metrics/ModuleLength
