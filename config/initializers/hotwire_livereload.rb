Rails.application.config.hotwire_livereload.force_reload_paths = %w[
  app/javascript
  app/assets/javascripts
].map { |p| Rails.root.join(p) }


Rails.application.config.hotwire_livereload.listen_paths += [
  "app/commands",
  "app/controllers",
  "app/models",
  "app/policies"
]

Rails.application.config.hotwire_livereload.css_bundling = true