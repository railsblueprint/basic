# frozen_string_literal: true

class AddFacebookPixelSettings < ActiveRecord::Migration[8.0]
  def up
    # Create Facebook Pixel section
    Setting.find_or_create_by(
      key:  "facebook_pixel_section",
      type: "section"
    ) do |s|
      s.description = "Facebook Pixel tracking configuration"
      s.value = nil
    end

    # Add Facebook Pixel ID setting with empty string
    Setting.find_or_create_by(
      key:  "facebook_pixel.id",
      type: "string"
    ) do |s|
      s.description = "Facebook Pixel ID"
      s.value = ""
    end

    # Add enabled flag - disabled by default
    Setting.find_or_create_by(
      key:  "facebook_pixel.enabled",
      type: "boolean"
    ) do |s|
      s.description = "Enable Facebook Pixel tracking"
      s.value = "false"
    end
  end

  def down
    Setting.where("key LIKE ?", "facebook_pixel%").destroy_all
    Setting.where(key: "facebook_pixel_section").destroy_all
  end
end
