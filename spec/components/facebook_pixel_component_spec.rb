# frozen_string_literal: true

require "rails_helper"

RSpec.describe FacebookPixelComponent, type: :component do
  describe "#render?" do
    context "when Facebook Pixel is enabled with valid ID" do
      before do
        AppConfig.set("facebook_pixel.enabled", true)
        AppConfig.set("facebook_pixel.id", "123456789012345")
      end

      it "renders the component" do
        expect(described_class.new.render?).to be true
      end
    end

    context "when Facebook Pixel is disabled" do
      before do
        AppConfig.set("facebook_pixel.enabled", false)
        AppConfig.set("facebook_pixel.id", "123456789012345")
      end

      it "does not render the component" do
        expect(described_class.new.render?).to be false
      end
    end

    context "when Facebook Pixel ID is missing" do
      before do
        AppConfig.set("facebook_pixel.enabled", true)
        AppConfig.set("facebook_pixel.id", nil)
      end

      it "does not render the component" do
        expect(described_class.new.render?).to be false
      end
    end

    context "when settings are missing" do
      it "does not render the component" do
        expect(described_class.new.render?).to be false
      end
    end
  end

  describe "rendered output" do
    context "when component is rendered" do
      before do
        AppConfig.set("facebook_pixel.enabled", true)
        AppConfig.set("facebook_pixel.id", "123456789012345")
      end

      it "includes the Facebook Pixel script" do
        rendered = render_inline(described_class.new)
        expect(rendered.to_html).to include("connect.facebook.net/en_US/fbevents.js")
        expect(rendered.to_html).to include("123456789012345")
      end

      it "includes the fbq init and track calls" do
        rendered = render_inline(described_class.new)
        expect(rendered.to_html).to include("fbq('init', '123456789012345')")
        expect(rendered.to_html).to include("fbq('track', 'PageView')")
      end

      it "includes the noscript fallback" do
        rendered = render_inline(described_class.new)
        expect(rendered.to_html).to include("https://www.facebook.com/tr?id=123456789012345")
        expect(rendered.to_html).to include("noscript")
      end
    end
  end
end
