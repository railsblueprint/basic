RSpec.describe "Admin Design system" do
  let(:admin) { create(:user, :admin) }
  let(:moderator) { create(:user, :moderator) }

  describe "GET /admin/design_system/colors" do
    context "when not logged in" do
      it "redirects to login page" do
        get "/admin/design_system/colors"
        expect(response).to redirect_to("/users/login")
      end
    end

    context "when does not have enough permissions" do
      it "redirects to login page" do
        sign_in moderator

        get "/admin/design_system/colors"
        expect(response).to redirect_to("/")
      end
    end

    context "when logged in as an admin" do
      it "returns http success" do
        sign_in admin

        get "/admin/design_system/colors"
        expect(response).to have_http_status(:success)
      end
    end
  end
end
