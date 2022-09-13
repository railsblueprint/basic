Rails.application.config.dartsass.builds = {
  "admin.scss"      => "admin.css",
  "frontend.scss"  => "frontend.css",
  "mail/foundation_emails.scss"  => "foundation_emails.css"
}

Rails.application.config.dartsass.build_options << " --quiet-deps"