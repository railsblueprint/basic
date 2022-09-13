RSpec.describe "Admin Mail Templates" do
  include_examples "admin crud controller", { resource: :mail_templates, model: MailTemplate, prefix: "config" }
  include_examples "admin crud controller empty search",
                   { resource: :mail_templates, model: MailTemplate, prefix: "config" }

  describe "GET /admin/config/mail_templates/:id/preview" do
    let(:mail_template) { create(:mail_template) }
    let(:admin) { create(:user, :superadmin) }

    before do
      sign_in admin
      get "/admin/config/mail_templates/#{mail_template.id}/preview"
    end

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /admin/config/mail_templates" do
    let!(:mail_template) { create(:mail_template, not_migrated: true) }
    let(:admin) { create(:user, :superadmin) }

    before do
      allow(Rails.env).to receive(:development?).and_return(true)

      # Reload model class
      Object.send(:remove_const, :MailTemplate)
      load "app/models/mail_template.rb"

      sign_in admin
      get "/admin/config/mail_templates"
    end

    it "shows migration warning" do
      expect(response.body).to include(CGI.escapeHTML(I18n.t("admin.mail_templates.header.you_have_unsaved_changes")))
    end
  end
end
