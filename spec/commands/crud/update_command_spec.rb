require "rails_helper"
RSpec.describe Crud::UpdateCommand, type: :command do
  subject { SampleModels::UpdateCommand.new(id: resource.id, current_user: user, attr: "123").no_exceptions! }

  before do
    stub_const("SampleModel", Class.new do
      attr_reader :id

      def self.find_by(...); end

      def initialize
        @id = "123"
      end

      def update(...) = true

      def errors
        ActiveModel::Errors.new(self)
      end
    end)

    stub_const("SampleModels", Module.new)
    stub_const("SampleModels::UpdateCommand", Class.new(Crud::UpdateCommand) do
                                                attribute :attr, Crud::UpdateCommand::Types::String
                                              end)
    stub_const("SampleModelPolicy", Class.new(ApplicationPolicy))
    allow(SampleModel).to receive(:find_by).and_return(resource)
  end

  let(:resource) { SampleModel.new }
  let(:user) { create(:user) }

  it "returns true as persisted?" do
    expect(subject.persisted?).to be(true)
  end

  context "when user has not enough permissions" do
    before do
      allow_any_instance_of(SampleModelPolicy).to receive(:update?).and_return(false)
    end

    it "broadcasts unauthorized event" do
      expect(subject).to broadcast(:unauthorized)
      subject.call
    end
  end

  context "when user has enough permissions" do
    before do
      allow_any_instance_of(SampleModelPolicy).to receive(:update?).and_return(true)
    end

    context "when resource is found" do
      it "calls update method on resource" do
        expect(resource).to receive(:update).with({ attr: "123" }).and_return(true)
        subject.call
      end

      it "broadcasts ok" do
        expect(subject).to broadcast(:ok)
        subject.call
      end
    end

    context "when update fails" do
      before do
        allow(resource).to receive(:update).with({ attr: "123" }).and_return(false)
      end

      it "broadcasts abort" do
        expect(subject).to broadcast(:abort)
        subject.call
      end
    end

    context "when id is not given" do
      subject { SampleModels::UpdateCommand.new(id: nil, current_user: user, attr: "123").no_exceptions! }

      it "broadcasts invalid" do
        expect(subject).to broadcast(:invalid)
        subject.call
      end
    end

    context "when resource is not found" do
      before do
        allow(SampleModel).to receive(:find_by).and_return(nil)
      end

      it "broadcasts invalid" do
        expect(subject).to broadcast(:invalid)
        subject.call
      end
    end
  end
end
