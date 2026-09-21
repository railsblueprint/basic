RSpec.describe "Admin Pages" do
  it_behaves_like "admin crud controller", resource: :pages, model: Page, has_filters: true
  it_behaves_like "admin crud controller paginated index", resource: :pages, model: Page, has_filters: true
  it_behaves_like "admin crud controller empty search", resource: :pages, model: Page, has_filters: true
  it_behaves_like "admin crud controller show resource", resource: :pages, model: Page, has_filters: true
  it_behaves_like "toggle boolean", { resource: :pages, attribute: :show_in_sidebar }
  it_behaves_like "toggle boolean", { resource: :pages, attribute: :active }
end
