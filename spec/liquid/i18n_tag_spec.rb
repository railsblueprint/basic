RSpec.describe "I18nTag" do
  let(:template) { "{% t actions.cancel %}" }
  let(:parsed_template) { Liquid::Template.parse(template) }

  it "translates the stirng" do
    expect(parsed_template.render({})).to eq("Cancel")
  end
end
