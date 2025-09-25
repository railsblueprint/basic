# frozen_string_literal: true

class FacebookPixelComponent < ViewComponent::Base
  def render?
    enabled? && facebook_pixel_id.present?
  end

  private

  def enabled?
    AppConfig.facebook_pixel&.enabled == true
  end

  def facebook_pixel_id
    AppConfig.facebook_pixel&.id
  end
end
