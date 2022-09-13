RSpec.shared_examples "toggle boolean" do |options|
  resource_name = options[:resource]
  attribute = options[:attribute]
  slug = [options[:prefix], options[:resource]].compact.join("/")

  let(:factory) { resource_name.to_s.singularize.to_sym }
  let(:admin) { create(:user, :superadmin) }
  let(:user) { create(:user) }

  describe "PATCH /admin/#{slug}/:id/toggle_#{attribute}" do
    let!(:resource) { create(factory) }

    context "when user has permission" do
      before do
        sign_in admin

        patch "/admin/#{slug}/#{resource.id}/toggle_#{attribute}"
      end

      it "redirect to the page" do
        expect(response).to have_http_status(:found)
      end

      it "changes attribute value" do
        expect { patch("/admin/#{slug}/#{resource.id}/toggle_#{attribute}") }.to(change {
                                                                                   resource.reload.send(attribute)
                                                                                 })
      end
    end

    context "when user does not have permission" do
      before do
        sign_in user

        patch "/admin/#{slug}/#{resource.id}/toggle_#{attribute}"
      end

      it "redirect to the page" do
        expect(response).to have_http_status(:found)
      end

      it "does not change attribute value" do
        expect { patch("/admin/#{slug}/#{resource.id}/toggle_#{attribute}") }.not_to(change {
                                                                                       resource.reload.send(attribute)
                                                                                     })
      end
    end
  end
end
