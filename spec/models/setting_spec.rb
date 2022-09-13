require "rails_helper"

RSpec.describe Setting do
  include Shoulda::Matchers::ActiveModel
  include Shoulda::Matchers::ActiveRecord

  let!(:invalid_json_setting) { create(:setting, alias: "invalid_setting", type: "json", value: "[") }
  let!(:array_setting) { create(:setting, alias: "array_setting", type: "json", value: [1, 2, 3].to_json) }
  let!(:json_setting) { create(:setting, alias: "json_setting", type: "json", value: { a: 1, b: 2 }.to_json) }
  let!(:string_setting) { create(:setting, alias: "string_setting", type: "string", value: "some_string") }

  it { is_expected.to have_db_column(:alias).of_type(:string) }
  it { is_expected.to have_db_column(:value).of_type(:string) }

  describe "class_methods" do
    describe "#type_text" do
      it "returns the type name" do
        expect(described_class.type_text(:integer)).to eq("Integer")
      end
    end

    describe "#method_missing" do
      it "calls []" do
        expect(described_class).to receive(:[]).with(:some_method)

        described_class.some_method
      end
    end

    describe "#[]" do
      it "returns the value", :aggregate_failures do
        expect(described_class[:string_setting]).to eq("some_string")
        expect(described_class[:array_setting]).to eq([1, 2, 3])
      end
    end

    describe "#to_liquid" do
      it "returns a hash with all values", :aggregate_failures do
        expect(described_class.to_liquid).to be_a(Hash)
        expect(described_class.to_liquid.keys.count).to eq(4)
      end
    end
  end

  describe "instance_methods" do
    describe "#type_text" do
      it "returns the type name" do
        expect(string_setting.type_text).to eq("String")
      end
    end

    describe "#parsed_json_value" do
      it "returns a Hash when hash value is given" do
        expect(json_setting.parsed_json_value).to be_a(Hash)
      end

      it "returns an Array when array value is given" do
        expect(array_setting.parsed_json_value).to be_an(Array)
      end

      it "returns nil when invalid value is given" do
        expect(invalid_json_setting.parsed_json_value).to be_nil
      end
    end
  end
end
