require "rails_helper"

RSpec.describe Post do
  include Shoulda::Matchers::ActiveModel
  include Shoulda::Matchers::ActiveRecord

  let(:hr_attachment) do
    '<action-text-attachment sgid="horizontal-rule" ' \
      'content-type="application/vnd.trix.horizontal-rule.html"></action-text-attachment>'
  end

  describe "associations" do
    subject { build(:post) }

    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_rich_text(:body) }
  end

  describe "#transliterated_title" do
    it "transliterates non-latin characters" do
      expect(build(:post, title: "Привет мир").transliterated_title).to eq("Privet mir")
    end

    it "handles latin characters normally" do
      expect(build(:post, title: "Hello World").transliterated_title).to eq("Hello World")
    end
  end

  describe "#cutline?" do
    let(:post) { create(:post) }

    context "when body is blank" do
      before { post.body = nil }

      it "returns false" do
        expect(post.cutline?).to be false
      end
    end

    context "when body contains a horizontal rule" do
      before { post.body = "First part#{hr_attachment}Second part" }

      it "returns true" do
        expect(post.cutline?).to be true
      end
    end

    context "when body does not contain a horizontal rule" do
      before { post.body = "Just regular content" }

      it "returns false" do
        expect(post.cutline?).to be false
      end
    end
  end

  describe "#teaser" do
    let(:post) { create(:post) }

    context "when post has no cutline" do
      before { post.body = "Just regular content" }

      it "returns the full body" do
        expect(post.teaser).to eq(post.body)
      end
    end

    context "when post has a cutline" do
      before do
        post.body = "<div>First part of content</div>#{hr_attachment}<div>Second part of content</div>"
      end

      it "returns only the content before the horizontal rule", :aggregate_failures do
        expect(post.teaser).to include("First part of content")
        expect(post.teaser).not_to include("Second part of content")
      end

      it "wraps the teaser in a trix-content div" do
        expect(post.teaser).to include('<div class="trix-content">')
      end

      it "returns an html safe string" do
        expect(post.teaser).to be_html_safe
      end
    end

    context "when the content above the cutline carries executable markup" do
      before do
        post.body = "<div><script>alert(1)</script>" \
                    '<img src=x onerror="xssProbe()">Above the fold</div>' \
                    "#{hr_attachment}<div>Below the fold</div>"
      end

      it "strips it", :aggregate_failures do
        expect(post.teaser).not_to include("<script")
        expect(post.teaser).not_to include("onerror")
        expect(post.teaser).to include("Above the fold")
      end
    end
  end
end
