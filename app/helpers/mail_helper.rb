module MailHelper
  def mail_template_layouts
    MailTemplate.available_layouts
                .map { |f| [t("mail_templates.names.#{f}"), f] }.sort
  end
end
