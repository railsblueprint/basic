# frozen_string_literal: true

require "rails_helper"

RSpec.describe YandexMetrikaComponent, type: :component do
  describe "#render?" do
    context "when Yandex Metrika is enabled with valid ID" do
      before do
        AppConfig.set("yandex_metrika.enabled", true)
        AppConfig.set("yandex_metrika.id", "12345678")
      end

      after do
        AppConfig.delete("yandex_metrika.enabled")
        AppConfig.delete("yandex_metrika.id")
      end

      it "renders the component" do
        expect(described_class.new.render?).to be true
      end

      it "includes Yandex Metrika script" do
        rendered = render_inline(described_class.new)
        expect(rendered.to_html).to include("mc.yandex.ru/metrika/tag.js")
        expect(rendered.to_html).to include("ym(12345678, 'init'")
      end

      it "includes noscript fallback" do
        rendered = render_inline(described_class.new)
        expect(rendered.to_html).to include("<noscript>")
        expect(rendered.to_html).to include("https://mc.yandex.ru/watch/12345678")
      end

      it "includes all tracking features" do
        rendered = render_inline(described_class.new)
        expect(rendered.to_html).to include("ssr:true")
        expect(rendered.to_html).to include("webvisor:true")
        expect(rendered.to_html).to include("clickmap:true")
        expect(rendered.to_html).to include("accurateTrackBounce:true")
        expect(rendered.to_html).to include("trackLinks:true")
        expect(rendered.to_html).to include('ecommerce:"dataLayer"')
      end
    end

    context "when Yandex Metrika is disabled" do
      before do
        AppConfig.set("yandex_metrika.enabled", false)
        AppConfig.set("yandex_metrika.id", "12345678")
      end

      after do
        AppConfig.delete("yandex_metrika.enabled")
        AppConfig.delete("yandex_metrika.id")
      end

      it "does not render the component" do
        expect(described_class.new.render?).to be false
      end
    end

    context "when Yandex Metrika ID is not configured" do
      before do
        AppConfig.set("yandex_metrika.enabled", true)
        AppConfig.set("yandex_metrika.id", "")
      end

      after do
        AppConfig.delete("yandex_metrika.enabled")
        AppConfig.delete("yandex_metrika.id")
      end

      it "does not render the component" do
        expect(described_class.new.render?).to be false
      end
    end

    context "when Yandex Metrika settings are not present" do
      before do
        AppConfig.delete("yandex_metrika.enabled") if AppConfig.yandex_metrika&.enabled
        AppConfig.delete("yandex_metrika.id") if AppConfig.yandex_metrika&.id
      end

      it "does not render the component" do
        expect(described_class.new.render?).to be false
      end
    end
  end
end
