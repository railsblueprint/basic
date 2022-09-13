describe Admin::DashboardController do
  render_views

  subject { post :show }

  let(:admin) { create(:user, :admin) }

  context "when logged in as admin" do
    it "renders ok" do
      sign_in admin

      get :show
      expect(response).to have_http_status(:ok)
    end
  end

  context "when not logged in" do
    it "redirects to login" do
      expect(subject).to redirect_to new_user_session_path

      expect(subject.request.flash[:alert]).not_to be_nil
    end
  end
end
