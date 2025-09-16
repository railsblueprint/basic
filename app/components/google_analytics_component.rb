# frozen_string_literal: true

class GoogleAnalyticsComponent < ViewComponent::Base
  def render?
    enabled? && google_analytics_id.present?
  end

  private

  def enabled?
    AppConfig.google_analytics.enabled == true
  end

  def google_analytics_id
    AppConfig.google_analytics.id
  end
end
