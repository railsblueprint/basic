describe Admin::DesignSystem::TablesController do
  render_views

  let(:admin) { create(:user, :admin) }

  %w[
    general
    data
  ].each do |chart_type|
    describe "renders page #{chart_type}" do
      it "renders ok" do
        sign_in admin

        get chart_type
        expect(response).to have_http_status(:ok)
      end
    end
  end
end
