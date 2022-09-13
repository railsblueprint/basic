describe Admin::DesignSystem::ComponentsController do
  render_views

  let(:admin) { create(:user, :admin) }

  %w[
    alerts
    accordion
    badges
    breadcrumbs
    buttons
    cards
    carousel
    list_group
    modal
    tabs
    pagination
    progress
    spinners
    tooltips
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
