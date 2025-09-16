# frozen_string_literal: true

class AddWebAnalyticsSettings < ActiveRecord::Migration[8.0]
  def up
    # Create Web Analytics section
    Setting.find_or_create_by(
      key:  "web_analytics",
      type: "section"
    ) do |s|
      s.description = "Web Analytics tracking configuration"
      s.value = nil
    end

    # Google Analytics settings
    Setting.find_or_create_by(
      key:  "google_analytics.id",
      type: "string"
    ) do |s|
      s.description = "Google Analytics measurement ID (G-XXXXXXXXXX)"
      s.value = ""
      s.section = "web_analytics"
    end

    Setting.find_or_create_by(
      key:  "google_analytics.enabled",
      type: "boolean"
    ) do |s|
      s.description = "Enable Google Analytics tracking"
      s.value = "false"
      s.section = "web_analytics"
    end

    # Facebook Pixel settings
    Setting.find_or_create_by(
      key:  "facebook_pixel.id",
      type: "string"
    ) do |s|
      s.description = "Facebook Pixel ID"
      s.value = ""
      s.section = "web_analytics"
    end

    Setting.find_or_create_by(
      key:  "facebook_pixel.enabled",
      type: "boolean"
    ) do |s|
      s.description = "Enable Facebook Pixel tracking"
      s.value = "false"
      s.section = "web_analytics"
    end
  end

  def down
    Setting.where("key LIKE ?", "google_analytics%").destroy_all
    Setting.where("key LIKE ?", "facebook_pixel%").destroy_all
    Setting.where(key: "web_analytics").destroy_all
  end
end
