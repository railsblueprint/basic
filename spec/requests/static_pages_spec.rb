RSpec.describe "Static pages" do
  let(:user) { create(:user) }

  describe "GET /" do
    context "when no custom home page is set" do
      before do
        get "/"
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end

      it "renders default home page", :aggregate_failures do
        expect(response).to render_template("static_pages/home")
        expect(response.body).to include("Welcome to Rails Blueprint")
      end
    end

    context "when a custom home page is set" do
      let!(:page) { create(:page, url: "", title: "HomePage", body: "Test homepage") }

      before do
        get "/"
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end

      it "renders template for page" do
        expect(response).to render_template("static_pages/page")
      end

      it "renders default home page" do
        expect(response.body).to include("Test homepage")
      end

      it "sets title" do
        expect(response.body).to have_tag("title", "Rails blueprint - commandments | HomePage")
      end

      it "sets SEO tags", :aggregate_failures do
        expect(response.body).to have_tag("meta[name=\"description\"]", with: { content: page.seo_description })
        expect(response.body).to have_tag("meta[name=\"keywords\"]", with: { content: "homepage" })
        expect(response.body).to have_tag("meta[name=\"seo_title\"]", with: { content: page.seo_title })
      end
    end
  end

  context "arbitrary page" do
    let!(:url) { "some/page" }

    context "when it does not exist" do
      it "returns http not_found" do
        expect { get "/#{url}" }.to raise_error(ActionController::RoutingError)
      end
    end

    context "when page exists" do
      let!(:page) { create(:page, url:, seo_keywords: "some, keywords") }

      before do
        get "/#{url}"
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end

      it "renders template for page" do
        expect(response).to render_template("static_pages/page")
      end

      it "renders default home page" do
        expect(response.body).to include(page.body)
      end

      it "sets title" do
        expect(response.body).to have_tag("title", "Rails blueprint - commandments | #{page.title}")
      end

      it "sets SEO tags", :aggregate_failures do
        expect(response.body).to have_tag("meta[name=\"description\"]", with: { content: page.seo_description })
        expect(response.body).to have_tag("meta[name=\"keywords\"]", with: { content: "some, keywords" })
      end
    end
  end
end
