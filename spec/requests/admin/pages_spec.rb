RSpec.describe "Admin Pages" do
  options = { resource: :pages, model: Page, has_filters: true }

  it_behaves_like "admin crud controller", options
  it_behaves_like "admin crud controller paginated index", options
  it_behaves_like "admin crud controller empty search", options
  it_behaves_like "admin crud controller show resource", options
  it_behaves_like "toggle boolean", { resource: :pages, attribute: :show_in_sidebar }
  it_behaves_like "toggle boolean", { resource: :pages, attribute: :active }
end
