require "rails_helper"
RSpec.describe Crud::CreateCommand, type: :command do
  subject { SampleModels::CreateCommand.new(attr: "qwe", current_user: user) }

  before do
    stub_const("SampleModel", Class.new do
      attr_reader :id

      def initialize(...)
        @id = "123"
      end

      def self.create(...)
        new(...)
      end

      def persisted? = true
    end)

    stub_const("SampleModels", Module.new)
    stub_const("SampleModels::CreateCommand", Class.new(Crud::CreateCommand) do
      attribute :attr, Crud::UpdateCommand::Types::String
    end)
    stub_const("SampleModelPolicy", Class.new(ApplicationPolicy))
  end

  let(:resource) { SampleModel.new }
  let(:user) { create(:user) }

  context "when user has not enough permissions" do
    before do
      allow_any_instance_of(SampleModelPolicy).to receive(:create?).and_return(false)
    end

    it "raises unathorized error" do
      expect { subject.call }.to raise_exception(BaseCommand::Unauthorized)
    end

    context "when listener present" do
      before do
        subject.on(:unauthorized) {} # rubocop:disable Lint/EmptyBlock
      end

      it "broadcasts unauthorized event" do
        expect { subject.call }.to broadcast(:unauthorized)
      end
    end
  end

  context "when user has enough permissions" do
    before do
      allow_any_instance_of(SampleModelPolicy).to receive(:create?).and_return(true)
    end

    context "when resource is found" do
      it "calls create method" do
        expect(SampleModel).to receive(:create).with({ attr: "qwe" })
                                               .and_return(instance_double(ActiveRecord::Base, persisted?: true))

        subject.call
      end

      it "broadcasts ok" do
        allow(SampleModel).to receive(:create).with({ attr: "qwe" })
                                              .and_return(instance_double(ActiveRecord::Base, persisted?: true))
        expect(subject).to broadcast(:ok)
        subject.call
      end
    end
  end
end
