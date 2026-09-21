RSpec.shared_examples "toggle boolean" do |options|
  slug = [options[:prefix], options[:resource]].compact.join("/")

  let(:attribute) { options[:attribute] }
  let(:factory) { options[:resource].to_s.singularize.to_sym }
  let(:admin) { create(:user, :superadmin) }
  let(:user) { create(:user) }

  describe "PATCH /admin/#{slug}/:id/toggle_#{options[:attribute]}" do
    let!(:resource) { create(factory) }
    let(:toggle_path) do
      "/admin/#{[options[:prefix], options[:resource]].compact.join('/')}/#{resource.id}/toggle_#{attribute}"
    end

    context "when user has permission" do
      before do
        sign_in admin

        patch toggle_path
      end

      it "redirect to the page" do
        expect(response).to have_http_status(:found)
      end

      it "changes attribute value" do
        expect { patch(toggle_path) }.to(change { resource.reload.send(attribute) })
      end
    end

    context "when user does not have permission" do
      before do
        sign_in user

        patch toggle_path
      end

      it "redirect to the page" do
        expect(response).to have_http_status(:found)
      end

      it "does not change attribute value" do
        expect { patch(toggle_path) }.not_to(change { resource.reload.send(attribute) })
      end
    end
  end
end
