require "rails_helper"
RSpec.describe Crud::DestroyCommand, type: :command do
  subject { SampleModels::DestroyCommand.new(id: resource.id, current_user: user).no_exceptions! }

  before do
    stub_const("SampleModel", Class.new do
                                attr_reader :id

                                def self.find_by(...); end

                                def initialize
                                  @id = "123"
                                end

                                def errors = ActiveModel::Errors.new(self)

                                def destroy = true # rubocop:disable Naming/PredicateMethod
                              end)

    stub_const("SampleModels", Module.new)
    stub_const("SampleModels::DestroyCommand", Class.new(described_class))

    stub_const("SampleModelPolicy", Class.new(ApplicationPolicy) do
                                      def destroy?; end
                                    end)
    allow(SampleModel).to receive(:find_by).and_return(resource)
  end

  let(:resource) { SampleModel.new }
  let(:user) { create(:user) }

  context "when user has not enough permissions" do
    before do
      allow_any_instance_of(SampleModelPolicy).to receive(:destroy?).and_return(false)
    end

    it "broadcasts unauthorized event" do
      expect(subject).to broadcast(:unauthorized)
      subject.call
    end
  end

  context "when user has enough permissions" do
    before do
      allow_any_instance_of(SampleModelPolicy).to receive(:destroy?).and_return(true)
    end

    context "when resource is found" do
      it "calls destroy method on resource" do
        expect(resource).to receive(:destroy)
        subject.call
      end

      it "broadcasts ok" do
        expect(subject).to broadcast(:ok)
        subject.call
      end
    end

    context "when id is not given" do
      subject { SampleModels::DestroyCommand.new(id: nil, current_user: user).no_exceptions! }

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
        expect { subject.call }.to broadcast(:invalid)
      end
    end
  end
end
