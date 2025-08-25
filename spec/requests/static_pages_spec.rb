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
        expect(response.body).to have_tag("title", "Rails Blueprint | HomePage")
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

    context "when page exists in database" do
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
        expect(response.body).to have_tag("title", "Rails Blueprint | #{page.title}")
      end

      it "sets SEO tags", :aggregate_failures do
        expect(response.body).to have_tag("meta[name=\"description\"]", with: { content: page.seo_description })
        expect(response.body).to have_tag("meta[name=\"keywords\"]", with: { content: "some, keywords" })
      end
    end
  end

  describe "automatic view rendering" do
    context "when accessing /faq without explicit route" do
      before do
        get "/faq"
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end

      it "renders the faq view template" do
        expect(response).to render_template("static_pages/faq")
      end

      it "includes content from the faq view" do
        expect(response.body).to include("section", "faq")
      end

      it "sets correct CSS classes on body tag" do
        expect(response.body).to match(/<body[^>]*class="[^"]*controller-static_pages[^"]*"/)
        expect(response.body).to match(/<body[^>]*class="[^"]*action-faq[^"]*"/)
      end
    end

    context "when accessing /about with view file" do
      before do
        get "/about"
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end

      it "renders the about view template" do
        expect(response).to render_template("static_pages/about")
      end

      it "includes content from the about view" do
        expect(response.body).to include("About Us")
        expect(response.body).to include("automatic view rendering")
      end

      it "sets correct CSS classes on body tag" do
        expect(response.body).to match(/<body[^>]*class="[^"]*controller-static_pages[^"]*"/)
        expect(response.body).to match(/<body[^>]*class="[^"]*action-about[^"]*"/)
      end
    end

    context "when database page exists and view file exists" do
      let!(:page) { create(:page, url: "faq", title: "Database FAQ", body: "Database content") }

      before do
        get "/faq"
      end

      it "prioritizes database page over view file" do
        expect(response).to render_template("static_pages/page")
        expect(response.body).to include("Database content")
        expect(response.body).not_to include("Frequently Asked Questions")
      end
    end

    context "when accessing nested path with view file" do
      before do
        # Create a nested view file for testing
        FileUtils.mkdir_p(Rails.root.join("app/views/static_pages/nested"))
        content = ".container\n  h1 Nested Page\n  p This is a nested page"
        Rails.root.join("app/views/static_pages/nested/page.html.slim").write(content)

        get "/nested/page"
      end

      after do
        # Clean up the test file
        FileUtils.rm_rf(Rails.root.join("app/views/static_pages/nested"))
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end

      it "renders the nested view template" do
        expect(response).to render_template("static_pages/nested/page")
      end

      it "sets correct CSS classes with dashes for nested paths" do
        expect(response.body).to match(/<body[^>]*class="[^"]*controller-static_pages[^"]*"/)
        expect(response.body).to match(/<body[^>]*class="[^"]*action-nested-page[^"]*"/)
      end
    end

    context "when neither database page nor view file exists" do
      it "returns 404" do
        expect { get "/nonexistent/page" }.to raise_error(ActionController::RoutingError)
      end
    end

    context "when accessing nested folder structure /about/team" do
      before do
        get "/about/team"
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end

      it "renders the nested view template" do
        expect(response).to render_template("static_pages/about/team")
      end

      it "includes content from the nested view" do
        expect(response.body).to include("Our Team")
        expect(response.body).to include("nested folder support")
      end

      it "sets correct CSS classes with hyphens for nested paths" do
        expect(response.body).to match(/<body[^>]*class="[^"]*controller-static_pages[^"]*"/)
        expect(response.body).to match(/<body[^>]*class="[^"]*action-about-team[^"]*"/)
      end
    end
  end
end
