RSpec.describe UniquenessValidator do
  let(:basic_command) do
    Class.new(BaseCommand) do
      adapter User
      include UniquenessValidator

      attribute :id, BaseCommand::Types::String
      attribute :email, BaseCommand::Types::String
      validates :email, uniqueness: true

      def process; end
    end
  end

  let(:conditional_command) do
    Class.new(BaseCommand) do
      adapter User
      include UniquenessValidator

      attribute :id, BaseCommand::Types::String
      attribute :email, BaseCommand::Types::String
      validates :email, uniqueness: { conditions: -> { where(last_name: "123") } }

      def process; end
    end
  end

  let(:conditional_with_arguments_command) do
    Class.new(BaseCommand) do
      adapter User
      include UniquenessValidator

      attribute :id, BaseCommand::Types::String
      attribute :email, BaseCommand::Types::String
      attribute :last_name, BaseCommand::Types::String
      validates :email, uniqueness: { conditions: ->(record) { where(last_name: record.last_name&.reverse) } }

      def process; end
    end
  end

  let(:advanced_command) do
    Class.new(BaseCommand) do
      adapter User
      include UniquenessValidator

      attribute :id, BaseCommand::Types::String
      attribute :email, BaseCommand::Types::String
      attribute :first_name, BaseCommand::Types::String
      validates :email, uniqueness: { scope: :first_name }

      def process; end
    end
  end

  context "when model does not have primary key" do
    subject { Command.new(id: SecureRandom.uuid, email: "test") }

    before do
      allow(User).to receive(:primary_key).and_return(nil)
      stub_const "Command", basic_command
    end

    it "raises exception" do
      expect { subject.call }.to raise_error(ActiveRecord::UnknownPrimaryKey)
    end
  end

  context "when model does have primary key" do
    before do
      stub_const "Command", basic_command
    end

    context "for new record" do
      subject { Command.new(email: "test@localhost") }

      context "when attribute is unique" do
        it "returns valid" do
          expect(subject).to be_valid
        end
      end

      context "when attribute is not unique" do
        let!(:user) { create(:user, email: "test@localhost") }

        it "returns invalid" do
          expect(subject).not_to be_valid
        end
      end
    end

    context "when condition is given" do
      subject { Command.new(email: "test@localhost") }

      before do
        stub_const "Command", conditional_command
      end

      context "when attribute is unique" do
        it "returns valid" do
          expect(subject).to be_valid
        end
      end

      context "when conditions are not met" do
        let!(:user) { create(:user, email: "test@localhost") }

        it "returns valid" do
          expect(subject).to be_valid
        end
      end

      context "when conditions are met and record is not unique" do
        let!(:user) { create(:user, email: "test@localhost", last_name: "123") }

        it "returns invalid" do
          expect(subject).not_to be_valid
        end
      end
    end

    context "when condition with argument is given" do
      subject { Command.new(email: "test@localhost", last_name: "123") }

      before do
        stub_const "Command", conditional_with_arguments_command
      end

      context "when attribute is unique" do
        it "returns valid" do
          expect(subject).to be_valid
        end
      end

      context "when conditions are not met" do
        let!(:user) { create(:user, email: "test@localhost") }

        it "returns valid" do
          expect(subject).to be_valid
        end
      end

      context "when conditions are met and record is not unique" do
        let!(:user) { create(:user, email: "test@localhost", last_name: "321") }

        it "returns invalid" do
          expect(subject).not_to be_valid
        end
      end
    end

    context "for existing record" do
      subject { Command.new(id: SecureRandom.uuid, email: "test@localhost") }

      context "when attribute is unique" do
        it "returns valid" do
          expect(subject).to be_valid
        end
      end

      context "when attribute is not unique" do
        let!(:user) { create(:user, email: "test@localhost") }

        it "returns invalid" do
          expect(subject).not_to be_valid
        end
      end

      context "when attribute is kept same" do
        subject { Command.new(id: user.id, email: "test@localhost") }

        let!(:user) { create(:user, email: "test@localhost") }

        it "returns valid" do
          expect(subject).to be_valid
        end
      end
    end

    context "scoped validation" do
      before do
        stub_const "Command", advanced_command
      end

      context "for new record" do
        subject { Command.new(email: "test@localhost", first_name: "123") }

        context "when attribute is unique" do
          it "returns valid" do
            expect(subject).to be_valid
          end
        end

        context "when attribute is not unique" do
          let!(:user) { create(:user, email: "test@localhost", first_name: "123") }

          it "returns invalid" do
            expect(subject).not_to be_valid
          end
        end

        context "when scope is different" do
          let!(:user) { create(:user, email: "test@localhost", first_name: "456") }

          it "returns invalid" do
            expect(subject).to be_valid
          end
        end
      end

      context "for existing record" do
        subject { Command.new(id: record.id, email: "test@localhost", first_name: "123") }

        let!(:record) { create(:user) }

        context "when attribute is unique" do
          it "returns valid" do
            expect(subject).to be_valid
          end
        end

        context "when attribute is not unique" do
          let!(:user) { create(:user, email: "test@localhost", first_name: "123") }

          it "returns invalid" do
            expect(subject).not_to be_valid
          end
        end

        context "when attribute scope is different" do
          let!(:user) { create(:user, email: "test@localhost", first_name: "456") }

          it "returns valid" do
            expect(subject).to be_valid
          end
        end

        context "when attribute is kept same" do
          subject { Command.new(id: user.id, email: "test@localhost", first_name: "123") }

          let!(:user) { create(:user, email: "test@localhost", first_name: "123") }

          it "returns valid" do
            expect(subject).to be_valid
          end
        end
      end
    end
  end
end
