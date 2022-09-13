RSpec.describe ApplicationPolicy do
  subject { described_class }

  # rubocop:disable RSpec/VerifiedDoubles
  let(:object) { double("test object", all: "all_objects", class: double("model", name: "Model", all: "all_objects")) }
  # rubocop:enable RSpec/VerifiedDoubles

  context "for guest user" do
    let(:user) { nil }

    permissions :index?, :show? do
      it { is_expected.to permit(user, object) }
    end

    permissions :edit?, :create?, :update?, :destroy?, :unknown? do
      it { is_expected.not_to permit(user, object) }
    end
  end

  context "for basic user" do
    let(:user) { build(:user) }

    permissions :index?, :show? do
      it { is_expected.to permit(user, object) }
    end

    permissions :edit?, :create?, :update?, :destroy?, :unknown? do
      it { is_expected.not_to permit(user, object) }
    end
  end

  context "for moderator user" do
    let(:user) { build(:user, :moderator) }

    permissions :index?, :show? do
      it { is_expected.to permit(user, object) }
    end

    permissions :edit?, :create?, :update?, :destroy?, :unknown? do
      it { is_expected.not_to permit(user, object) }
    end
  end

  context "for admin user" do
    let(:user) { build(:user, :admin) }

    permissions :index?, :show?, :edit?, :create?, :update?, :destroy?, :unknown? do
      it { is_expected.to permit(user, object) }
    end
  end

  context "for superadmin user" do
    let(:user) { build(:user, :admin) }

    permissions :index?, :show?, :edit?, :create?, :update?, :destroy?, :unknown? do
      it { is_expected.to permit(user, object) }
    end
  end

  describe "#respond_to_missing?" do
    subject { described_class.new(user, object) }

    let(:user) { build(:user, :admin) }

    it "responds to all methods" do
      expect(subject).to respond_to(:junk?)
    end
  end

  describe "#scope" do
    subject { described_class.new(user, object) }

    let(:user) { build(:user, :admin) }

    before do
      stub_const("RSpec::Mocks::DoublePolicy", Class.new(described_class))
    end

    it "responds to all methods" do
      expect(subject.scope).to eq("all_objects")
    end
  end

  describe "Scope" do
    let(:user) { build(:user, :admin) }
    let(:scope) { described_class::Scope.new(user, object) }

    it "returns all objects" do
      expect(scope.resolve).to eq("all_objects")
    end
  end
end
