RSpec.describe "Admin Users" do
  options = { resource: :users, model: User, has_filters: true }
  let(:admin) { create(:user, :superadmin) }

  it_behaves_like "admin crud controller", options
  it_behaves_like "admin crud controller paginated index", options
  it_behaves_like "admin crud controller show resource", options

  describe "GET /admin/users" do
    let!(:testuser) { create(:user, first_name: "test") }
    let!(:otheruser) { create(:user, first_name: "other") }

    before do
      sign_in admin
      get "/admin/users/?q=test"
    end

    it "returns a 200 status code" do
      expect(response).to be_successful
    end

    it "finds user", :aggregate_failures do
      expect(response.body).to include(testuser.last_name)
      expect(response.body).not_to include(otheruser.last_name)
    end
  end

  describe "GET /admin/users/lookup" do
    let!(:testuser) { create(:user, first_name: "test") }

    before do
      sign_in admin
      get "/admin/users/lookup?q=test"
    end

    it "returns a 200 status code" do
      expect(response).to be_successful
    end

    it "renders json" do
      expect(response.content_type).to eq("application/json; charset=utf-8")
    end

    it "finds user and renders json" do
      expect(response.parsed_body).to eq({
        results:    [{ id: testuser.id, text: testuser.full_name }],
        pagination: { more: false }
      }.deep_stringify_keys)
    end
  end

  describe "password change functionality" do
    let(:user) { create(:user) }
    let(:valid_password_attributes) do
      {
        user: {
          password:              "newpassword123",
          password_confirmation: "newpassword123"
        }
      }
    end

    before do
      sign_in admin
    end

    describe "PATCH /admin/users/:id/update_password" do
      context "with valid password and confirmation" do
        it "updates the user's password" do
          patch update_password_admin_user_path(user), params: valid_password_attributes

          expect(response).to redirect_to(edit_admin_user_path(user))
          expect(flash[:success]).to be_present

          # Verify password was actually changed
          user.reload
          expect(user.valid_password?("newpassword123")).to be true
        end

        it "sends password change email to user" do
          expect {
            patch update_password_admin_user_path(user), params: valid_password_attributes
          }.to have_enqueued_mail(TemplateMailer, :email).with(:password_change,
                                                               hash_including(to: user.email, user: user))
        end
      end

      context "with mismatched password confirmation" do
        it "does not update the password" do
          attributes = valid_password_attributes.deep_dup
          attributes[:user][:password_confirmation] = "different"

          patch update_password_admin_user_path(user), params: attributes
          expect(response).to have_http_status(:unprocessable_entity)

          # Verify password was not changed
          user.reload
          expect(user.valid_password?("newpassword123")).to be false
        end
      end

      context "with short password" do
        it "does not update the password" do
          attributes = valid_password_attributes.deep_dup
          attributes[:user][:password] = "short"
          attributes[:user][:password_confirmation] = "short"

          patch update_password_admin_user_path(user), params: attributes
          expect(response).to have_http_status(:unprocessable_entity)

          # Verify password was not changed
          user.reload
          expect(user.valid_password?("short")).to be false
        end
      end
    end

    describe "PUT /admin/users/:id" do
      context "with blank password" do
        it "updates other attributes without changing password" do
          attributes = {
            user: {
              first_name: "Updated"
            }
          }

          old_encrypted_password = user.encrypted_password

          put admin_user_path(user), params: attributes
          expect(response).to redirect_to(edit_admin_user_path(user))

          user.reload
          expect(user.first_name).to eq("Updated")
          expect(user.encrypted_password).to eq(old_encrypted_password)
        end
      end
    end

    describe "password field visibility" do
      it "shows password fields to admin users" do
        get edit_admin_user_path(user)
        expect(response.body).to include("password")
        expect(response.body).to include("password_confirmation")
      end
    end
  end
end
