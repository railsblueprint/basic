class TemplateMailer < ActionMailer::Base
  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  # TODO: refactor
  def email template_alias, params={}
    params = params.with_indifferent_access

    template = MailTemplate.find_by(alias: template_alias)

    if template.blank?
      Rails.logger.error "Mail template #{template_alias} not found!"
      return
    end

    body = template.body
    subject = template.subject

    body = render inline: body.html_safe, layout: "layouts/mail/#{template.layout}"
    template_body = Liquid::Template.parse(body)

    template_subject = Liquid::Template.parse(subject)

    if params[:attachments].present?
      params[:attachments].each { |k, v|
        attachments[k] = v
      }
    end

    mail(from:         Setting.sender_email,
         to:           params[:to],
         reply_to:     params[:reply_to],
         bcc:          params[:bcc],
         subject:      template_subject.render(params),
         body:         template_body.render(params),
         content_type: "text/html")
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
end