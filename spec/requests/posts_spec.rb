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
