RSpec.describe CrudBase do
  render_views false

  controller(ApplicationController) do
    include CrudBase # rubocop:disable RSpec/DescribedClass

    def model
      Page
    end

    def load_resource; end
  end

  with_routing do |routes|
    routes.draw do
      resources :anonymous
    end
  end

  before do
    stub_const "Anonymous", Module.new
    stub_command("Anonymous::CreateCommand", :ok,
                 instance_double(ActiveRecord::Base, model_name: "Anonymous", id: 1))
    stub_command("Anonymous::UpdateCommand", :ok,
                 instance_double(ActiveRecord::Base, model_name: "Anonymous", id: 1))
    stub_command("Anonymous::DestroyCommand", :ok,
                 instance_double(ActiveRecord::Base, model_name: "Anonymous", id: 1))
  end

  describe "#index" do
    it "succeeds" do
      get :index

      expect(response).to be_successful
    end
  end

  context "show" do
    it "succeeds" do
      get :new

      expect(response).to be_successful
    end
  end

  describe "#new" do
    it "succeeds" do
      get :new

      expect(response).to be_successful
    end
  end

  describe "#create" do
    it "redirects to edit page" do
      post :create
      expect(response).to redirect_to("/anonymous/1/edit")
      expect(flash[:success]).to eq("Successfully created Page")
    end

    context "with errors" do
      before do
        stub_command("Anonymous::CreateCommand", :invalid) do |errors|
          errors.add(:name, "can't be blank")
        end
      end

      it "renders error" do
        post :create
        expect(response).to render_template("new")
        expect(response).to have_http_status :unprocessable_entity
        expect(flash[:error]).to eq({
          message: "Failed to create Page",
          details: ["Name can't be blank"]
        })
      end
    end

    context "when aborted" do
      before do
        stub_command("Anonymous::CreateCommand", :abort) do |errors|
          errors.add(:name, "can't be blank")
        end
      end

      it "renders error" do
        post :create
        expect(response).to render_template("new")
        expect(response).to have_http_status :unprocessable_entity
        expect(flash[:error]).to eq({
          message: "Failed to create Page",
          details: ["Name can't be blank"]
        })
      end
    end

    context "when not authorized" do
      before do
        stub_command("Anonymous::CreateCommand", :unauthorized)
      end

      it "renders error" do
        post :create
        expect(response).to redirect_to("/anonymous")
        expect(flash[:error]).to eq "You are not authorized to create Page"
      end
    end
  end

  describe "#edit" do
    it "succeeds" do
      get :edit, params: { id: 1 }

      expect(response).to be_successful
    end
  end

  describe "#update" do
    it "succeeds" do
      patch :update, params: { id: 1 }

      expect(response).to redirect_to("/anonymous/1/edit")
      expect(flash[:success]).to eq("Successfully updated Page")
    end

    context "with errors" do
      before do
        stub_command("Anonymous::UpdateCommand", :invalid) do |errors|
          errors.add(:name, "can't be blank")
        end
      end

      it "renders error" do
        patch :update, params: { id: 1 }

        expect(response).to render_template("edit")
        expect(response).to have_http_status(:unprocessable_entity)
        expect(flash[:error]).to eq({
          message: "Failed to update Page",
          details: ["Name can't be blank"]
        })
      end
    end

    context "when aborted" do
      before do
        stub_command("Anonymous::UpdateCommand", :abort) do |errors|
          errors.add(:name, "can't be blank")
        end
      end

      it "renders error" do
        patch :update, params: { id: 1 }
        expect(response).to render_template("edit")
        expect(response).to have_http_status :unprocessable_entity
        expect(flash[:error]).to eq({
          message: "Failed to update Page",
          details: ["Name can't be blank"]
        })
      end
    end

    context "when not authorized" do
      before do
        stub_command("Anonymous::UpdateCommand", :unauthorized)
      end

      it "renders error" do
        patch :update, params: { id: 1 }
        expect(response).to redirect_to("/anonymous")
        expect(flash[:error]).to eq "You are not authorized to update this Page"
      end
    end
  end

  describe "#destroy" do
    it "succeeds" do
      delete :destroy, params: { id: 1 }

      expect(response).to redirect_to("/anonymous")
    end
  end

  context "with errors" do
    before do
      stub_command("Anonymous::DestroyCommand", :invalid) do |errors|
        errors.add(:name, "can't be blank")
      end
    end

    it "renders error" do
      delete :destroy, params: { id: 1 }

      expect(response).to redirect_to("/anonymous")
      expect(flash[:error]).to eq({
        message: "Failed to delete Page",
        details: ["Name can't be blank"]
      })
    end
  end

  context "when aborted" do
    before do
      stub_command("Anonymous::DestroyCommand", :abort) do |errors|
        errors.add(:name, "can't be blank")
      end
    end

    it "renders error" do
      delete :destroy, params: { id: 1 }

      expect(response).to redirect_to("/anonymous")
      expect(flash[:error]).to eq({
        message: "Failed to delete Page",
        details: ["Name can't be blank"]
      })
    end
  end

  context "when not authorized" do
    before do
      stub_command("Anonymous::DestroyCommand", :unauthorized)
    end

    it "renders error" do
      delete :destroy, params: { id: 1 }
      expect(response).to redirect_to("/anonymous")
      expect(flash[:error]).to eq "You are not authorized to delete this Page"
    end
  end
end
