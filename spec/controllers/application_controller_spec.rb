RSpec.describe ApplicationController do
  describe "rescue from pundit errors" do
    controller do
      before_action do
        authorize :test
      end

      def index
        render plain: "test"
      end

      def show
        render_404
      end
    end

    before do
      stub_const("TestPolicy", Class.new(ApplicationPolicy) do
                                 def index? = false
                               end)
    end

    context "when condition" do
      context "get request" do
        it "redirects to root" do
          get :index

          expect(response).to redirect_to(root_path)

          expect(flash[:error]).to eq(I18n.t("messages.you_cannot_access_this_page"))
        end
      end

      context "post request" do
        it "redirects to root" do
          post :index

          expect(response).to redirect_to(root_path)
          expect(flash[:error]).to eq(I18n.t("messages.you_cannot_peform_this_action"))
        end
      end
    end
  end

  describe "#render_404" do
    controller do
      def index
        render_404
      end
    end

    it "raises ActionController::RoutingError" do
      expect { get :index }.to raise_error(ActionController::RoutingError)
    end
  end
end
