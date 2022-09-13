def escape(value)
  value.to_s.gsub('"', '\"').gsub(/\n/m, "\\n\" \\\n          \"")
end

# rubocop:disable Metrics/BlockLength:
namespace :mail_templates do
  desc "Generate migration for new mail_templates"
  task generate: :environment do
    code = MailTemplate.unscoped.where(not_migrated: true).where(deleted_at: nil).map { |template|
      <<-CODEEND
    unless MailTemplate.where("alias": "#{template.alias}").any?
      MailTemplate.create(
        "alias":     "#{template.alias}",
        subject:      "#{template.subject}",
        body:         "#{escape template.body}",
        layout:       "#{template.layout}",
      )
    end
      CODEEND
    }.join

    code += MailTemplate.unscoped.where.not(deleted_at: nil).where(not_migrated: false).map { |template|
      <<-CODEEND
    MailTemplate.where("alias": "#{template.alias}").delete_all
      CODEEND
    }.join

    MailTemplate.unscoped.where(not_migrated: true).update_all(not_migrated: false)
    MailTemplate.unscoped.where.not(deleted_at: nil).delete_all

    if code.present?
      time = Time.current.strftime("%Y%m%d%H%M%S")
      timestamp = Time.now.to_i
      filename = "#{time}_create_mail_templates#{timestamp}.rb"
      body = <<~CODEEND
        class CreateMailTemplates#{timestamp} < ActiveRecord::Migration[7.0]
          def up
        #{code}
          end

          def down
          end
        end
      CODEEND

      File.write("db/data/#{filename}", body)
      puts "Generating file db/data/#{filename}"
    else
      puts "No new templates found"
    end
  end
end
# rubocop:enable Metrics/BlockLength:
