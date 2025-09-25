# frozen_string_literal: true

class AddYandexMetrikaSettings < ActiveRecord::Migration[8.0]
  def up
    # Ensure Web Analytics section exists
    Setting.find_or_create_by(
      key:  "web_analytics",
      type: "section"
    ) do |s|
      s.description = "Web Analytics tracking configuration"
      s.value = nil
    end

    # Yandex Metrika settings
    Setting.find_or_create_by(
      key:  "yandex_metrika.id",
      type: "string"
    ) do |s|
      s.description = "Yandex Metrika counter ID"
      s.value = ""
      s.section = "web_analytics"
    end

    Setting.find_or_create_by(
      key:  "yandex_metrika.enabled",
      type: "boolean"
    ) do |s|
      s.description = "Enable Yandex Metrika tracking"
      s.value = "false"
      s.section = "web_analytics"
    end
  end

  def down
    Setting.where("key LIKE ?", "yandex_metrika%").destroy_all
  end
end
