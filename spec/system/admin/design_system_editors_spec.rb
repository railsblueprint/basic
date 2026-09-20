RSpec.describe "Admin design system editors" do
  let!(:admin) { create(:user, :admin) }

  it "renders the suneditor toolbar without fetching a relative design stylesheet", :aggregate_failures do
    visit "/users/login"
    fill_in "Email", with: admin.email
    fill_in "Password", with: admin.password
    click_button "Log in"
    expect(page).to have_text(admin.short_name)

    visit "/admin/design_system/forms/editors"

    expect(page).to have_css(".sun-editor .se-toolbar button", minimum: 10)

    requested = page.evaluate_script("performance.getEntriesByType('resource').map(e => e.name)")
    expect(requested).not_to include(a_string_ending_with("design/index.css"))
  end
end
