require "rails_helper"
RSpec.describe Crud::CreateCommand, type: :command do
  before do
    stub_const("SampleModel", Class.new do
      attr_reader :id
      def initialize(...)
        @id = "123"
      end

      def self.create(...)
        new(...)
      end
    end
    )

    stub_const("SampleModels", Module.new)
    stub_const("SampleModels::CreateCommand", Class.new(Crud::CreateCommand) do
      attribute :attr, Crud::UpdateCommand::Types::String
    end
    )
    stub_const("SampleModelPolicy" , Class.new(ApplicationPolicy))
  end

  let(:resource) {SampleModel.new}
  let(:user) { create(:user) }

  subject { SampleModels::CreateCommand.new(attr: "qwe", current_user: user) }

  context "when user has not enough permissions" do
    before do
      allow_any_instance_of(SampleModelPolicy).to receive(:create?).and_return(false)
    end

    it "broadcasts unauthorized event" do
      expect(subject).to broadcast(:unauthorized)
      subject.call
    end
  end

  context "when user has enough permissions" do
    before do
      allow_any_instance_of(SampleModelPolicy).to receive(:create?).and_return(true)
    end

    context "when resource is found" do
      it "calls create method " do
        expect(SampleModel).to receive(:create).with({attr: "qwe"})
        subject.call
      end

      it "broadcasts ok" do
        expect(subject).to broadcast(:ok)
        subject.call
      end
    end
  end
end
