describe BaseCommand do
  before do
    # rubocop:disable RSpec/DescribedClass
    stub_const("BadCommand",
               Class.new(BaseCommand))
    stub_const("SampleCommand",
               Class.new(BaseCommand) do
                 def process; end
               end)
    stub_const("WithArgumentsCommand",
               Class.new(BaseCommand) do
                 attribute :a, BaseCommand::Types::String
                 validates :a, presence: true
                 def process; end
               end)
    stub_const("NonTransactionalCommand",
               Class.new(BaseCommand) do
                 skip_transaction!
                 def process; end
               end)
    stub_const("AbortedCommand",
               Class.new(BaseCommand) do
                 skip_transaction!

                 def process
                   abort_command
                   second_step
                 end

                 def second_step; end
               end)
    # rubocop:enable RSpec/DescribedClass
  end

  let(:command_class) do
    SampleCommand
  end

  let(:command_with_arguments_class) do
    WithArgumentsCommand
  end

  let(:non_transactional_class) do
    NonTransactionalCommand
  end

  let(:class_with_abort) do
    AbortedCommand
  end

  context "class methods" do
    subject { command_class }

    context "when process is not defined" do
      it "raises exception" do
        expect { BadCommand.call }.to raise_error("Interface not implemented")
      end
    end

    context "when requested to run now" do
      it "instanciates the command and invokes call" do
        expect_any_instance_of(subject).to receive(:call)
        subject.call
      end
    end

    context "when called with ActionController::Parameters" do
      let(:command_class) { WithArgumentsCommand }
      let(:expected_params) {
        {
          a:       "abc",
          user_id: "123"
        }
      }
      let(:additional_params) {
        {
          user_id: "123"
        }
      }
      let(:params) {
        ActionController::Parameters.new({
          with_arguments_command: {
            a:     "abc",
            other: "def"
          },
          ignored_params:         {
            key: "123"
          }
        })
      }

      it "permits correct parameters" do
        expect(subject).to receive(:call).with(expected_params) # rubocop:disable RSpec/SubjectStub

        subject.call_for params, additional_params
      end
    end

    context "when requested to run in background" do
      it "instanciates the command and checks preflight conditions" do
        expect_any_instance_of(subject).to receive(:preflight_nok?)
        subject.call_later
      end

      context "when preflight checks are ok" do
        it "creates background job" do
          expect_any_instance_of(subject).to receive(:preflight_nok?).and_return(false)
          expect(DelayedCommandJob).to receive(:perform_later)
          subject.call_later
        end
      end

      context "when preflight checks are not ok" do
        it "does not create background job" do
          expect_any_instance_of(subject).to receive(:preflight_nok?).and_return(true)
          expect(DelayedCommandJob).not_to receive(:perform_later)
          subject.call_later
        end
      end
    end

    context "when invoked with delay" do
      let(:delay) { { wait: 5.minutes } }

      it "instanciates the command and checks preflight conditions" do
        expect_any_instance_of(subject).to receive(:preflight_nok?)
        subject.call_at(delay)
      end

      context "when preflight checks are ok" do
        it "creates background job" do
          expect_any_instance_of(subject).to receive(:preflight_nok?).and_return(false)
          expect(DelayedCommandJob).to receive(:set).and_call_original
          subject.call_at(delay)
        end
      end

      context "when preflight checks are not ok" do
        it "does not create background job" do
          expect_any_instance_of(subject).to receive(:preflight_nok?).and_return(true)
          expect(DelayedCommandJob).not_to receive(:set).and_call_original
          subject.call_at(delay)
        end
      end
    end

    context "when called with mixed hash and keyword arguments" do
      it "accepts both hash and keyword arguments in new" do
        command = command_with_arguments_class.new({ a: "from_hash" }, a: "from_kwargs")
        expect(command.a).to eq("from_kwargs") # kwargs should override hash
      end

      it "accepts both hash and keyword arguments in call" do
        expect(command_with_arguments_class).to receive(:new)
          .with({ a: "from_hash" }, a: "from_kwargs").and_call_original
        command_with_arguments_class.call({ a: "from_hash" }, a: "from_kwargs") do |cmd|
          cmd.on(:ok) { true }
        end
      end

      it "accepts only hash argument" do
        expect(command_with_arguments_class).to receive(:new).with({ a: "test" }).and_call_original
        command_with_arguments_class.call({ a: "test" }) do |cmd|
          cmd.on(:ok) { true }
        end
      end

      it "accepts only keyword arguments" do
        expect(command_with_arguments_class).to receive(:new).with(nil, a: "test").and_call_original
        command_with_arguments_class.call(a: "test") do |cmd|
          cmd.on(:ok) { true }
        end
      end
    end
  end

  context "instance methods" do
    subject { command_class.new }

    it "returns false as persisited? by default" do
      expect(subject.persisted?).to be(false)
    end

    context "when subclass of this command is #call'ed" do
      context "with valid parameters" do
        before do
          allow(subject).to receive(:valid?).and_return(true) # rubocop:disable RSpec/SubjectStub
        end

        it "calls broadcast_ok" do
          expect { subject.call }.to broadcast(:ok)
        end
      end

      context "with invalid parameters" do
        before do
          allow(subject).to receive(:valid?).and_return(false) # rubocop:disable RSpec/SubjectStub
        end

        it "raises error when there is no listener added" do
          expect { subject.call }.to raise_exception(BaseCommand::Invalid)
        end

        context "when there is a listener added" do
          before do
            subject.on(:invalid) {} # rubocop:disable Lint/EmptyBlock
          end

          it "broadcasts invalid" do
            expect { subject.call }.to broadcast(:invalid)
          end

          it "raises no error" do
            expect { subject.call }.not_to raise_exception
          end
        end
      end

      context "with missing parameters and loose mode" do
        subject { command_with_arguments_class.new }

        it "calls broadcast_invalid" do
          expect(subject).to receive(:broadcast_invalid) # rubocop:disable RSpec/SubjectStub
          subject.call
        end

        it "does not raise exception" do
          expect { subject }.not_to raise_exception
        end
      end

      context "when command is transactional" do
        it "runs in transaction block" do
          expect(ActiveRecord::Base).to receive(:transaction).and_call_original
          subject.call
        end
      end

      context "when command is non-transactional" do
        subject { non_transactional_class.new }

        it "runs without transaction block" do
          expect(ActiveRecord::Base).not_to receive(:transaction)
          subject.call
        end
      end
    end

    context "when command is aborted using #abort_command" do
      subject { class_with_abort.new }

      it "raises exception when there is no listener to abort" do
        expect { subject.call }.to raise_error(BaseCommand::AbortCommand)
      end

      context "when abort listener is added" do
        before do
          subject.on(:abort) {} # rubocop:disable Lint/EmptyBlock
        end

        it "broadcasts :abort with errors" do
          expect { subject.call }.to broadcast(:abort, subject.errors)
          expect { subject.call }.not_to raise_error
        end

        it "prevents further execution" do
          expect(subject).not_to receive(:second_step) # rubocop:disable RSpec/SubjectStub
          subject.call
        end
      end
    end
  end
end
