RSpec.describe "Users pages" do
  let(:user) { create(:user, password: "12345678") }
  let(:other_user) { create(:user) }

  describe "GET /profile" do
    context "when not logged in" do
      it "returns not found" do
        expect { get "/profile" }.to raise_error(ActionController::RoutingError)
      end
    end

    context "when loggen in" do
      before do
        sign_in user
        get "/profile"
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end

      it "renders user's profile" do
        expect(response.body).to include(user.full_name)
      end

      it "include link to edit profile" do
        expect(response.body).to have_tag("a", "Edit profile")
      end
    end
  end

  describe "GET /users/:id" do
    context "when not logged in" do
      before do
        get "/users/#{other_user.id}"
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end

      it "renders user's profile" do
        expect(response.body).to include(CGI.escapeHTML(other_user.full_name))
      end

      it "does not include link to edit profile" do
        expect(response.body).not_to have_tag("a", "Edit profile")
      end
    end

    context "when logged in" do
      before do
        sign_in user
        get "/users/#{other_user.id}"
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end

      it "renders user's profile" do
        expect(response.body).to include(CGI.escapeHTML(other_user.full_name))
      end

      it "does not include link to edit profile" do
        expect(response.body).not_to have_tag("a", "Edit profile")
      end
    end

    context "when logged in as same user" do
      before do
        sign_in user
        get "/users/#{user.id}"
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end

      it "renders user's profile" do
        expect(response.body).to include(CGI.escapeHTML(user.full_name))
      end

      it "includes link to edit profile" do
        expect(response.body).to have_tag("a", "Edit profile")
      end
    end
  end

  describe "GET /profile/edit" do
    context "when not logged in" do
      before do
        get "/profile/edit"
      end

      it "redirects to login page" do
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when logged in" do
      before do
        sign_in user
        get "/profile/edit"
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end

      it "includes forms", :aggregate_failures do
        expect(response.body).to have_form "/profile/edit", :post
        expect(response.body).to have_form "/profile/password", :post
      end
    end
  end

  describe "POST /profile/password" do
    context "when not logged in" do
      before do
        post "/profile/password",
             params: { user: { current_password: "<PASSWORD>", password: "<PASSWORD>",
password_confirmation: "<PASSWORD>" } }
      end

      it "redirects to login page" do
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when logged in" do
      context "with valid params" do
        before do
          sign_in user
          post "/profile/password",
               params: { user: { current_password: "12345678", password: "87654321",
password_confirmation: "87654321" } }
        end

        it "redirects to profile page", :aggregate_failures do
          expect(response).to redirect_to(profile_path)
          expect(flash[:success]).to eq("Your password has been changed.")
          expect(flash[:turbo_breakout]).to be(true)
        end
      end

      context "with invalid params" do
        before do
          sign_in user
          post "/profile/password",
               params: { user: {
                 current_password: "bad_password", password: "87654321", password_confirmation: "87654321"
               } }
        end

        it "redirects to profile page", :aggregate_failures do
          expect(response).to have_http_status(:unprocessable_entity)
          expect(flash[:error]).to eq("Failed to update password.")
        end
      end
    end
  end

  describe "PATH /profile/edit" do
    context "when not logged in" do
      before do
        patch "/profile/edit", params: { user: { first_name: "123" } }
      end

      it "redirects to login page" do
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when logged in" do
      context "with valid params" do
        before do
          sign_in user
          patch "/profile/edit", params: { user: { first_name: "123" } }
        end

        it "redirects to profile page", :aggregate_failures do
          expect(response).to redirect_to(profile_path)
          expect(flash[:success]).to eq("Your profile has been updated")
          expect(flash[:turbo_breakout]).to be(true)
        end
      end

      context "with invalid params" do
        before do
          sign_in user
          patch "/profile/edit", params: { user: { facebook_profile: "123" } }
        end

        it "redirects to profile page", :aggregate_failures do
          expect(response).to have_http_status(:unprocessable_entity)
          expect(flash[:error]).to eq("Failed to update profile")
        end
      end
    end
  end
end
