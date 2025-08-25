namespace :bootstrap_icons do
  desc "Update Bootstrap Icons design system page with all icons from npm package"
  task update_design_system: :environment do
    require "json"

    json_path = Rails.root.join("node_modules/bootstrap-icons/font/bootstrap-icons.json")
    unless File.exist?(json_path)
      puts "Error: bootstrap-icons npm package not found. Run 'yarn install' first."
      exit 1
    end

    icons_data = JSON.parse(File.read(json_path))
    icon_names = icons_data.keys.sort

    puts "Found #{icon_names.length} icons"

    # Generate the Slim template
    template = <<~SLIM
      div data-controller='admin--demo-icons'
        section.section
          p
            |  Use the following pattern to add the Bootstrap icons to anywhere in your project.
          p
            code
              | i.bi.bi-
              strong
                | alarm-fill
          p or with a helper
          p
            code
              | = bi '
              strong
                | alarm-fill
              |'

          p
            '  Replace the bold part with the below icon names. Check the
            a[href="https://icons.getbootstrap.com/" target="_blank"]
              | Official website
            |  for more info.
          .input-group
            .input-group-text
              i.i.bi.bi-search
            input.form-control autocomplete="off" name="q" type="search" data-action="input->admin--demo-icons#search"

          .iconslist
    SLIM

    # Add each icon with proper indentation
    icon_names.each do |icon_name|
      template += "      .icon\n"
      template += "        i.bi.bi-#{icon_name}\n"
      template += "        .label\n"
      template += "          | #{icon_name}\n"
    end

    # Write the file
    output_path = Rails.root.join("app/views/admin/design_system/icons/bootstrap.html.slim")
    File.write(output_path, template)

    puts "Successfully updated #{output_path}"
    puts "Total icons: #{icon_names.length}"
  end
end
