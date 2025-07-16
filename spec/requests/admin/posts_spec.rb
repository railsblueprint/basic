RSpec.describe "Admin Posts" do
  let(:admin) { create(:user, :admin) }
  let(:moderator) { create(:user, :moderator) }
  let!(:page_size) { Post.default_per_page }

  options = { resource: :posts, model: Post, has_filters: true }

  it_behaves_like "admin crud controller", options
  it_behaves_like "admin crud controller paginated index", options
  it_behaves_like "admin crud controller empty search", options
  it_behaves_like "admin crud controller show resource", options

  describe "GET /admin/posts" do
    before do
      sign_in admin

      get "/admin/posts"
    end

    # context "when there are no posts" do
    #   it "says there are no posts" do
    #     expect(response.body).to include("No posts found")
    #   end
    #
    #   it "includes a link to create a new post" do
    #     expect(response.body).to have_tag("a.btn.btn-primary", seen: "Create")
    #   end
    #
    #   it "2 header lines" do
    #     expect(response.body).to have_tag("li.item.item-container", count: 2)
    #   end
    #
    #   it "renders search form" do
    #     expect(response.body).to have_form "/admin/posts", :get
    #
    #   end
    # end

    context "when there is less than one page" do
      let!(:posts) { create_list(:post, 10) }

      before do
        sign_in admin

        get "/admin/posts"
      end

      it "renders posts", :aggregate_failures do
        posts.each do |post|
          expect(response.body).to have_tag("div.attribute", seen: post.user.full_name, count: 1)
          expect(response.body).to have_tag("div.attribute", seen: post.title, count: 1)
        end
      end
    end

    context "when searching by title" do
      let!(:posts) { create_list(:post, page_size + 15) }
      let!(:post) { create(:post, title: "___SEARCH__TERM___") }

      before do
        sign_in admin

        get "/admin/posts?q=___SEARCH__TERM___"
      end

      it "finds post", :aggregate_failures do
        expect(response.body).to include("Displaying <b>1</b> post")

        expect(response.body).to have_tag("div.attribute", seen: post.title, count: 1)
        expect(response.body).to have_tag("li.item.item-container", count: 3)
      end
    end

    context "when searching by user" do
      let!(:posts) { create_list(:post, page_size + 15) }
      let!(:post) { create(:post) }

      before do
        sign_in admin

        get "/admin/posts?user_id=#{post.user.id}"
      end

      it "finds post", :aggregate_failures do
        expect(response.body).to include("Displaying <b>1</b> post")

        expect(response.body).to have_tag("div.attribute", seen: post.title, count: 1)
        expect(response.body).to have_tag("li.item.item-container", count: 3)
      end
    end
  end

  describe "GET /admin/posts/:id" do
    let!(:post) { create(:post) }

    before do
      sign_in admin

      get "/admin/posts/#{post.id}"
    end

    it "renders successfully", :aggregate_failures do
      expect(response.body).to include(post.title)
      expect(response.body).to include(post.body.to_s)
    end

    it "includes link to the user", :aggregate_failures do
      expect(response.body).to have_tag("a", with: { href: "/admin/users/#{post.user_id}" })
      expect(response.body).to include(CGI.escapeHTML(post.user.full_name))
    end
  end

  describe "PATCH /admin/posts/:id" do
    let!(:post) { create(:post) }

    let(:params) {
      {
        post: {
          title:   "new title",
          body:    post.body.to_s,
          user_id: post.user_id
        }
      }
    }

    before do
      sign_in admin

      patch "/admin/posts/#{post.id}", params:
    end

    it "redirects to edit page", :aggregate_failures do
      expect(response).to redirect_to("/admin/posts/#{post.id}/edit")
      expect(flash[:success]).to match(/Successfully updated/)
    end

    it "updates the post" do
      expect(post.reload.title).to eq("new title")
    end
  end

  describe "POST /admin/posts" do
    let!(:user) { create(:user) }

    let(:params) {
      {
        post: {
          title:   "new title",
          body:    "new body",
          user_id: user.id
        }
      }
    }

    before do
      sign_in admin

      post "/admin/posts", params:
    end

    it "renders successfully", :aggregate_failures do
      post = user.posts.first

      expect(response).to redirect_to("/admin/posts/#{post.id}/edit")
      expect(flash[:success]).to match(/Successfully created/)
    end

    it "creates a new post" do
      expect(user.posts.count).to eq(1)
    end
  end
end
