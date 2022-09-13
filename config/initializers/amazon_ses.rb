require "aws-sdk-rails"

creds = Aws::Credentials.new(Rails.application.credentials.dig(:ses, :user_id), Rails.application.credentials.dig(:ses, :access_key))
ses_server = Rails.application.credentials.dig(:ses, :server)
region = (ses_server && ses_server.scan(/email\.(.*)\.amazonaws\.com/).flatten.first) || "us-east-1"

Aws::Rails.add_action_mailer_delivery_method(:ses, credentials: creds, region: region)
