# frozen_string_literal: true

class YandexMetrikaComponent < ViewComponent::Base
  def render?
    enabled? && yandex_metrika_id.present?
  end

  private

  def enabled?
    AppConfig.yandex_metrika&.enabled == true
  end

  def yandex_metrika_id
    AppConfig.yandex_metrika&.id
  end
end
