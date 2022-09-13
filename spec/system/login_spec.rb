RSpec.describe "Auth" do
  describe "Login" do
    let!(:user) { create(:user) }

    it "can login", :aggregate_failures do
      visit root_path
      click_link "Login"

      fill_in "Email", with: user.email
      fill_in "Password", with: user.password

      click_button "Log in"
      expect(page).to have_content(user.short_name)
      expect(page).to have_content("Signed in successfully")
    end
  end

  describe "Register" do
    it "can login", :aggregate_failures do
      visit root_path
      click_link "Sign up"

      fill_in "First name", with: "John"
      fill_in "Last name", with: "Doe"
      fill_in "Email", with: "johndoe@example.com"
      fill_in "Password", with: "12345678"
      fill_in "Password confirmation", with: "12345678"

      click_button "Sign up"

      find(".controller-static_pages.action-home")

      user = User.order(:created_at).last

      expect(user.first_name).to eq("John")
      expect(user.last_name).to eq("Doe")
      expect(user.email).to eq("johndoe@example.com")

      expect(page).to have_content("A message with a confirmation link has been sent")
    end
  end
end
