RSpec.describe ToggleBoolean do
  controller(ApplicationController) do
    include CrudBase
    include ToggleBoolean # rubocop:disable RSpec/DescribedClass

    toggle_boolean :active

    def show; end

    def model
      Page
    end
  end

  let(:page) { Page.create(title: "test", active: true) }

  with_routing do |routes|
    routes.draw do
      post "/anonymous/toggle_active"
      get "/anonymous/show/:id", controller: "anonymous", action: "show"
      get "/anonymous/show", controller: "anonymous", action: "show"
      resources :anonymous
    end
  end

  describe "#toggle_active" do
    context "when user is anonymous" do
      it "does not change value" do
        post :toggle_active, params: { id: page.id }

        expect(page.reload.active).to be(true)

        expect(flash[:error]).to eq I18n.t("admin.common.not_authorized")
      end
    end

    context "when user has permissions" do
      before do
        sign_in create(:user, :admin)
      end

      it "succeeds" do
        post :toggle_active, params: { id: page.id }

        expect(page.reload.active).to be(false)

        expect(flash[:success]).to eq I18n.t("admin.common.successfully_updated")
      end

      context "format turbostream" do
        it "renders tibo-stream" do
          post :toggle_active, params: { id: page.id }, format: :turbo_stream
          expect(response.content_type).to eq("text/vnd.turbo-stream.html; charset=utf-8")
        end
      end
    end
  end
end
