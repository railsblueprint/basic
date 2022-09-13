RSpec.describe "Admin Pages" do
  options = { resource: :pages, model: Page, has_filters: true }

  include_examples "admin crud controller", options
  include_examples "admin crud controller paginated index", options
  include_examples "admin crud controller empty search", options
  include_examples "admin crud controller show resource", options
  include_examples "toggle boolean", { resource: :pages, attribute: :show_in_sidebar }
  include_examples "toggle boolean", { resource: :pages, attribute: :active }
end
