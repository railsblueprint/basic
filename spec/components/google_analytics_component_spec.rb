# frozen_string_literal: true

require "rails_helper"

RSpec.describe GoogleAnalyticsComponent, type: :component do
  describe "#render?" do
    context "when Google Analytics is enabled with valid ID" do
      before do
        AppConfig.set("google_analytics.enabled", true)
        AppConfig.set("google_analytics.id", "G-TEST123456")
      end

      it "renders the component" do
        expect(described_class.new.render?).to be true
      end
    end

    context "when Google Analytics is disabled" do
      before do
        AppConfig.set("google_analytics.enabled", false)
        AppConfig.set("google_analytics.id", "G-TEST123456")
      end

      it "does not render the component" do
        expect(described_class.new.render?).to be false
      end
    end

    context "when Google Analytics ID is missing" do
      before do
        AppConfig.set("google_analytics.enabled", true)
        AppConfig.set("google_analytics.id", nil)
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
        AppConfig.set("google_analytics.enabled", true)
        AppConfig.set("google_analytics.id", "G-TEST123456")
      end

      it "includes the Google Analytics script tag" do
        rendered = render_inline(described_class.new)
        expect(rendered.css("script[src*='googletagmanager.com']")).to be_present
        expect(rendered.to_html).to include("G-TEST123456")
      end

      it "includes the gtag configuration" do
        rendered = render_inline(described_class.new)
        expect(rendered.to_html).to include("gtag('config', 'G-TEST123456')")
      end
    end
  end
end
