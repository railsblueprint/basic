RSpec.describe "Admin Dashboard" do
  let(:admin) { create(:user, :admin) }
  let(:user) { create(:user) }

  describe "GET /admin" do
    context "when not logged in" do
      before do
        get "/admin"
      end

      it "redirects to login page" do
        expect(response).to redirect_to(new_user_session_path)
      end

      it "shows flash message" do
        expect(flash[:alert]).to eq("You need to sign in or sign up before continuing.")
      end
    end

    context "when logged as regular user" do
      before do
        sign_in user
        get "/admin"
      end

      it "redirects to home page" do
        expect(response).to redirect_to(root_path)
      end

      it "shows flash message" do
        expect(flash[:error]).to eq("You cannot access this page")
      end
    end

    context "when logged as admin user" do
      before do
        sign_in admin
        get "/admin"
      end

      it "renders the page" do
        expect(response).to be_successful
      end
    end
  end

  describe "GET /adminsearch" do
    context "when not logged in" do
      before do
        get "/admin/search?q=test"
      end

      it "redirects to login page" do
        expect(response).to redirect_to(new_user_session_path)
      end

      it "shows flash message" do
        expect(flash[:alert]).to eq("You need to sign in or sign up before continuing.")
      end
    end

    context "when logged as regular user" do
      before do
        sign_in user
        get "/admin/search?q=test"
      end

      it "redirects to home page" do
        expect(response).to redirect_to(root_path)
      end

      it "shows flash message" do
        expect(flash[:error]).to eq("You cannot access this page")
      end
    end

    context "when logged as admin user" do
      let!(:user) { create(:user, first_name: "test") }

      before do
        sign_in admin
        get "/admin/search?q=test"
      end

      it "renders the page", :aggregate_failures do
        expect(response).to be_successful
        expect(response.body).to have_tag(".collection li.item")
      end
    end
  end
end
