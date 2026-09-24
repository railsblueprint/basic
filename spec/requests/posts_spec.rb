RSpec.describe "Posts page" do
  let(:user) { create(:user) }

  describe "GET /blog" do
    context "when logged in" do
      before do
        sign_in user
        get "/blog"
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end
    end

    context "when not logged in" do
      let!(:resources) { create_list(:post, 7) }

      it "returns http success" do
        get "/blog"
        expect(response).to have_http_status(:success)
      end

      it "render first 5 posts" do
        get "/blog"
        expect(response.body).to have_tag(".card.post", count: 5)
      end

      it "render last 2 posts" do
        get "/blog?page=2"
        expect(response.body).to have_tag(".card.post", count: 2)
      end
    end

    context "when logged as post author" do
      let(:user) { create(:user) }
      let!(:resources) { create_list(:post, 5, user:) }

      before do
        sign_in user
        get "/blog"
      end

      it "shows control buttons", :aggregate_failures do
        get "/blog"
        expect(response.body).to have_tag(".card.post a", text: /Edit/, count: 5)
        expect(response.body).to have_tag(".card.post a", text: /Delete/, count: 5)
      end
    end

    context "when logged as moderator" do
      let(:moderator) { create(:user, :moderator) }
      let!(:resources) { create_list(:post, 5) }

      before do
        sign_in moderator
        get "/blog"
      end

      it "shows control buttons", :aggregate_failures do
        expect(response.body).to have_tag(".card.post a", text: /Edit/, count: 5)
        expect(response.body).to have_tag(".card.post a", text: /Delete/, count: 5)
      end
    end

    context "with a long post" do
      let!(:resource) { create(:post, body: "#{'word ' * 100}needle-at-the-end") }

      before { get "/blog" }

      it "truncates the body" do
        expect(response.body).not_to include("needle-at-the-end")
      end

      it "shows a read more link" do
        expect(response.body).to have_tag(".card.post a[href='/blog/#{resource.slug}']", text: /Read more/)
      end

      it "wraps the card in a preview element, not the show page's body element", :aggregate_failures do
        expect(response.body).to have_tag("div", with: { id: "post_#{resource.id}_preview" })
        expect(response.body).not_to have_tag("div", with: { id: "post_#{resource.id}_body" })
      end
    end

    context "with a short post" do
      let!(:resource) { create(:post, body: "Short and sweet") }

      before { get "/blog" }

      it "shows the whole body" do
        expect(response.body).to include("Short and sweet")
      end

      it "does not show a read more link" do
        expect(response.body).not_to have_tag(".card.post a", text: /Read more/)
      end
    end

    context "with a long post containing html entities" do
      let(:entities) { "R&amp;D at Rails &amp; Ruby: 5 &lt; 6." }
      let!(:resource) { create(:post, body: "<div>#{entities}</div><div>#{'tail ' * 80}</div>") }

      before { get "/blog" }

      it "escapes the entities exactly once", :aggregate_failures do
        expect(response.body).to have_tag(".card.post", text: /R&D at Rails & Ruby: 5 < 6\./)
        expect(response.body).not_to include("&amp;amp;")
      end
    end

    context "with a post whose text fits but whose markup does not" do
      let!(:resource) { create(:post, body: "<div>#{'a' * 125}</div><div>#{'b' * 125}</div>") }

      before { get "/blog" }

      it "shows the whole body", :aggregate_failures do
        expect(response.body).to include("a" * 125)
        expect(response.body).to include("b" * 125)
      end

      it "does not show a read more link" do
        expect(response.body).not_to have_tag(".card.post a", text: /Read more/)
      end
    end

    context "with a post that has a cutline" do
      let(:hr_attachment) do
        '<action-text-attachment sgid="horizontal-rule" ' \
          'content-type="application/vnd.trix.horizontal-rule.html"></action-text-attachment>'
      end
      let!(:resource) { create(:post, body: "<div>Above the fold</div>#{hr_attachment}<div>Below the fold</div>") }

      before { get "/blog" }

      it "shows the teaser only", :aggregate_failures do
        expect(response.body).to include("Above the fold")
        expect(response.body).not_to include("Below the fold")
      end

      it "shows a read more link" do
        expect(response.body).to have_tag(".card.post a[href='/blog/#{resource.slug}']", text: /Read more/)
      end
    end

    context "with a post whose teaser carries executable markup" do
      let(:hr_attachment) do
        '<action-text-attachment sgid="horizontal-rule" ' \
          'content-type="application/vnd.trix.horizontal-rule.html"></action-text-attachment>'
      end
      let!(:resource) do
        create(:post, body: "<div><script>alert(1)</script>" \
                            '<img src=x onerror="xssProbe()">Above the fold</div>' \
                            "#{hr_attachment}<div>Below the fold</div>")
      end

      before { get "/blog" }

      it "strips it before rendering the card", :aggregate_failures do
        expect(response.body).not_to have_tag(".card.post script")
        expect(response.body).not_to include("xssProbe")
        expect(response.body).to include("Above the fold")
      end
    end
  end

  describe "GET /blog/new" do
    let!(:user) { create(:user) }

    context "when not logged in" do
      before do
        sign_out :user
        get "/blog/new"
      end

      it "redirects to login page" do
        expect(response).to redirect_to(new_user_session_path)
      end

      it "shows flash message" do
        expect(flash[:alert]).to eq("You need to sign in or sign up before continuing.")
      end
    end

    context "when logged in" do
      before do
        sign_in user
        get "/blog/new"
      end

      it "renders ok" do
        expect(response).to be_successful
      end

      it "renders form" do
        expect(response.body).to have_form("/blog", :post)
      end
    end
  end

  describe "POST /blog" do
    let!(:user) { create(:user) }
    let(:params) { { post: { title: "title", body: "content" } } }

    context "when not logged in" do
      before do
        post "/blog", params:
      end

      it "redirects to login page" do
        expect(response).to redirect_to(new_user_session_path)
      end

      it "shows flash message" do
        expect(flash[:alert]).to eq("You need to sign in or sign up before continuing.")
      end
    end

    context "when logged in" do
      before do
        sign_in user
        post "/blog", params:
      end

      it "redirect to new post" do
        expect(response).to redirect_to(%r{/blog/.+/edit})
      end

      it "creates a new post" do
        expect(Post.count).to eq(1)
      end
    end
  end

  describe "GET /blog/:id" do
    let!(:user) { create(:user) }
    let!(:post) { create(:post, user:) }
    let(:params) { { post: { title: "title", body: "content" } } }

    context "when not logged in" do
      before do
        get "/blog/#{post.id}"
      end

      it "renders the post" do
        expect(response).to be_successful
      end

      it "shows the body", :aggregate_failures do
        expect(response.body).to include(ERB::Util.h(post.title))
        expect(response.body).to include(post.body.to_s)
      end

      it "wraps the post in a body element, not the index card's preview element", :aggregate_failures do
        expect(response.body).to have_tag("div", with: { id: "post_#{post.id}_body" })
        expect(response.body).not_to have_tag("div", with: { id: "post_#{post.id}_preview" })
      end

      it "does not show control buttons", :aggregate_failures do
        expect(response.body).not_to have_tag(".card.post a", text: /Edit/, count: 1)
        expect(response.body).not_to have_tag(".card.post a", text: /Delete/, count: 1)
      end
    end

    context "when logged in as a different user" do
      let(:other_user) { create(:user) }

      before do
        sign_in other_user
        get "/blog/#{post.id}"
      end

      it "renders the post" do
        expect(response).to be_successful
      end

      it "shows the body", :aggregate_failures do
        expect(response.body).to include(ERB::Util.h(post.title))
        expect(response.body).to include(post.body.to_s)
      end

      it "does not show control buttons", :aggregate_failures do
        expect(response.body).not_to have_tag(".card.post a", text: /Edit/, count: 1)
        expect(response.body).not_to have_tag(".card.post a", text: /Delete/, count: 1)
      end
    end

    context "when logged as author" do
      before do
        sign_in user
        get "/blog/#{post.id}"
      end

      it "renders the post" do
        expect(response).to be_successful
      end

      it "shows the body", :aggregate_failures do
        expect(response.body).to include(ERB::Util.h(post.title))
        expect(response.body).to include(post.body.to_s)
      end

      it "shows control buttons", :aggregate_failures do
        expect(response.body).to have_tag(".card.post a", text: /Edit/, count: 1)
        expect(response.body).to have_tag(".card.post a", text: /Delete/, count: 1)
      end
    end

    context "when logged as moderator" do
      let(:moderator) { create(:user, :moderator) }

      before do
        sign_in moderator
        get "/blog/#{post.id}"
      end

      it "renders the post" do
        expect(response).to be_successful
      end

      it "shows the body", :aggregate_failures do
        expect(response.body).to include(ERB::Util.h(post.title))
        expect(response.body).to include(post.body.to_s)
      end

      it "shows control buttons", :aggregate_failures do
        expect(response.body).to have_tag(".card.post a", text: /Edit/, count: 1)
        expect(response.body).to have_tag(".card.post a", text: /Delete/, count: 1)
      end
    end
  end

  describe "PATCH /blog/:id" do
    let!(:user) { create(:user) }
    let!(:post) { create(:post, user:) }
    let(:long_body) { "<div>#{'word ' * 100}needle-at-the-end</div>" }
    let(:morphs) do
      ActionCable.server.pubsub
                 .broadcasts(PostChannel.broadcasting_for(post))
                 .flat_map { |message| JSON.parse(message)["operations"] }
                 .select { |operation| operation["operation"] == "morph" }
                 .index_by { |operation| operation["selector"] }
    end

    before do
      sign_in user
      patch "/blog/#{post.id}", params: { post: { title: post.title, body: long_body } }
    end

    it "updates the post" do
      expect(post.reload.body.to_s).to include("needle-at-the-end")
    end

    it "morphs both the preview and the full body" do
      expect(morphs.keys).to contain_exactly("#post_#{post.id}_preview", "#post_#{post.id}_body")
    end

    it "sends the truncated preview to the index card", :aggregate_failures do
      preview = morphs["#post_#{post.id}_preview"]["html"]

      expect(preview).not_to include("needle-at-the-end")
      expect(preview).to include("Read more")
    end

    it "sends the full body to the show page", :aggregate_failures do
      body = morphs["#post_#{post.id}_body"]["html"]

      expect(body).to include("needle-at-the-end")
      expect(body).not_to include("Read more")
    end
  end

  describe "GET /blog/:id/edit" do
    let!(:user) { create(:user) }
    let!(:post) { create(:post, user:) }
    let(:params) { { post: { title: "title", body: "content" } } }

    context "when not logged in" do
      before do
        get "/blog/#{post.id}/edit"
      end

      it "redirects to login page" do
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when logged in as a different user" do
      let(:other_user) { create(:user) }

      before do
        sign_in other_user
        get "/blog/#{post.id}/edit"
      end

      it "redirects to home page" do
        expect(response).to redirect_to(root_path)
      end
    end

    context "when logged as author" do
      before do
        sign_in user
        get "/blog/#{post.id}/edit"
      end

      it "renders ok" do
        expect(response).to be_successful
      end

      it "shows the form" do
        expect(response.body).to have_form("/blog/#{post.id}", :post)
      end
    end

    context "when logged as moderator" do
      let(:moderator) { create(:user, :moderator) }

      before do
        sign_in moderator
        get "/blog/#{post.id}/edit"
      end

      it "renders ok" do
        expect(response).to be_successful
      end

      it "shows the form" do
        expect(response.body).to have_form("/blog/#{post.id}", :post)
      end
    end
  end
end
