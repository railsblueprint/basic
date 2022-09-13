class Admin::MailTemplatesController < Admin::CrudController
  def actions_with_resource
    base_actions_with_resource + [:preview]
  end

  def index
    super
    return unless Rails.env.development?

    @unsaved = MailTemplate.unsaved.any?
  end

  def filter_resources
    @resources = @resources.where("alias like :q ", q: "%#{params[:q]}%") if params[:q].present?
  end

  def order_resources
    @resources = @resources.order(:alias)
  end

  def no_show_action? = true

  def name_attribute
    :alias
  end

  def preview
    parsed = Liquid::Template.parse(@resource.body)
    body = parsed.render(template_attributes, {}).html_safe # rubocop:disable Rails/OutputSafety

    render html: body, layout: "layouts/mail/#{@resource.layout}"
  end

  def template_attributes
    @resource.body.scan(/{{(.*?)}}/).map { |match|
      unfold_string_to_hash(match.first.strip.split("."), match.first.strip)
    }.reduce(&:deep_merge)
  end

  def unfold_string_to_hash(key_parts, value)
    { key_parts[0] => key_parts.size == 1 ? value : unfold_string_to_hash(key_parts[1..], value) }
  end
end
