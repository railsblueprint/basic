require "rails_helper"

RSpec.describe User do
  include Shoulda::Matchers::ActiveModel
  include Shoulda::Matchers::ActiveRecord

  it { is_expected.to have_db_column(:email).of_type(:string) }

  describe "associations" do
    it { is_expected.to have_many(:posts) }
  end

  describe "methods" do
    let(:user) { create(:user, first_name: "Foo", last_name: "Bar") }
    let(:russian) { create(:user, first_name: "Вася", last_name: "Пупкин") }
    let(:complex_name) { create(:user, first_name: "Foo Long", last_name: "Bar") }
    let(:anonymous) { create(:user, first_name: "", last_name: "") }

    let(:admin) { create(:user, :admin) }
    let(:superadmin) { create(:user, :superadmin) }

    describe "#full_name" do
      it "concatenates first_name and last_name" do
        expect(user.full_name).to eq("Foo Bar")
      end

      it "returns email when both names are blank" do
        expect(anonymous.full_name).to eq(anonymous.email)
      end
    end

    describe "#short_name" do
      it "concatenates first_name initial and last_name" do
        expect(user.short_name).to eq("F. Bar")
      end

      it "returns email when both names are blank" do
        expect(anonymous.short_name).to eq(anonymous.email)
      end
    end

    describe "#initials" do
      it "returns 2 first letters of names" do
        expect(user.initials).to eq("FB")
      end

      it "returns initials of 2 first words when first_name has spaces" do
        expect(complex_name.initials).to eq("FL")
      end

      it "works for non-latin letters" do
        expect(russian.initials).to eq("ВП")
      end

      it "returns 2 symbols of email" do
        expect(anonymous.initials).to eq(anonymous.email[0..1])
      end
    end

    describe "#avatar_color" do
      it "returns 4 when initials are FB" do
        expect(user.avatar_color).to eq(4)
      end
    end

    describe "#has_role" do
      it "returns true when user has role" do
        expect(admin).to have_role(:admin)
      end

      it "returns false when user don't have role" do
        expect(admin).not_to have_role(:other_role)
      end

      it "returns true for any role when user has superadmin role" do
        expect(superadmin).to have_role(:other_role)
      end
    end
  end
end
