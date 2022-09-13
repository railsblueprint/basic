RSpec.describe "Admin Settings" do
  let(:admin) { create(:user, :superadmin) }

  describe "CRUD operations" do
    before do
      allow(Rails.env).to receive(:development?).and_return(true)

      # Reload model class
      Object.send(:remove_const, :Setting)
      load "app/models/setting.rb"
    end

    include_examples "admin crud controller", { resource: :settings, model: Setting, prefix: "config" }
  end

  describe "GET /admin/config/settings" do
    context "not dev environment" do
      let!(:setting_group) { create(:setting, type: :set) }
      let!(:setting) { create(:setting, type: :string, set: setting_group) }

      before do
        sign_in admin
        get "/admin/config/settings"
      end

      it "does not show edit settings links", :aggregate_failures do
        expect(response.body).not_to have_tag("a", with: { href: edit_admin_setting_path(setting_group) })
        expect(response.body).not_to have_tag("a", with: { href: edit_admin_setting_path(setting) })
      end

      it "does not shows create settings button" do
        expect(response.body).not_to have_tag("a", with: { href: new_admin_setting_path })
      end

      it "shows save button" do
        expect(response.body).to have_tag("input[type=submit]")
      end
    end

    context "dev environment" do
      let!(:setting_group) { create(:setting, type: :set) }
      let!(:setting) { create(:setting, type: :string, set: setting_group.alias) }

      before do
        allow(Rails.env).to receive(:development?).and_return(true)

        # Reload model class
        Object.send(:remove_const, :Setting)
        load "app/models/setting.rb"

        sign_in admin
      end

      context "when user is superadmin" do
        context "and editing enabled" do
          before do
            get "/admin/config/settings"
          end

          it "shows edit settings links", :aggregate_failures do
            expect(response.body).to have_tag("a", with: { href: edit_admin_setting_path(setting_group) })
            expect(response.body).to have_tag("a", with: { href: edit_admin_setting_path(setting) })
          end

          it "shows create settings button" do
            expect(response.body).to have_tag("a", with: { href: new_admin_setting_path })
          end
        end

        context "and editing disabled" do
          let!(:disable_settings_editor) {
            create(:setting, type: :boolean, set: setting_group, alias: "disable_settings_editor", value: true)
          }

          before do
            get "/admin/config/settings"
          end

          it "does not show edit settings links", :aggregate_failures do
            expect(response.body).not_to have_tag("a", with: { href: edit_admin_setting_path(setting_group) })
            expect(response.body).not_to have_tag("a", with: { href: edit_admin_setting_path(setting) })
          end

          it "does not shows create settings button" do
            expect(response.body).not_to have_tag("a", with: { href: new_admin_setting_path })
          end
        end
      end

      context "when user is simpleadmin" do
        let(:admin) { create(:user, :admin) }

        before do
          get "/admin/config/settings"
        end

        it "does not show edit settings links", :aggregate_failures do
          expect(response.body).not_to have_tag("a", with: { href: edit_admin_setting_path(setting_group) })
          expect(response.body).not_to have_tag("a", with: { href: edit_admin_setting_path(setting) })
        end

        it "does not shows create settings button" do
          expect(response.body).not_to have_tag("a", with: { href: new_admin_setting_path })
        end
      end
    end
  end

  describe "POST /admin/config/settings/mass_update" do
    let(:setting_group) { create(:setting, type: :set) }
    let(:setting) { create(:setting, type: :string, set: setting_group) }

    before do
      sign_in admin
      post "/admin/config/settings/mass_update", params:
    end

    context "with valid params" do
      let(:params) {
        {
          settings: {
            setting.id => { value: "new value" }
          }
        }
      }

      it "redirects to the settings page" do
        expect(response).to redirect_to(admin_settings_path)
      end

      it "shows success messakge" do
        expect(flash[:success]).to be_present
      end
    end

    context "with invalid params" do
      let(:params) {
        {
          settings: {
            "123" => { value: "new value" }
          }
        }
      }

      it "redirects to the settings page" do
        expect(response).to redirect_to(admin_settings_path)
      end

      it "shows success message" do
        expect(flash[:error]).to be_present
      end
    end
  end
end
