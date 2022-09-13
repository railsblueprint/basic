describe DelayedCommandJob do
  before do
    stub_const("GoodCommand", Class.new(BaseCommand) do
                                def process; end
                              end)
    stub_const("AbortedCommand", Class.new(BaseCommand) do
                                   def process
                                     abort_command
                                   end
                                 end)
    stub_const("WrongClass", Class.new)
  end

  let(:klass) { GoodCommand }
  let(:arguments) { { a: 1, b: "2" } }
  let(:run) do
    described_class.new.perform(klass, arguments)
  end

  context "when called with correct class" do
    it "does not log errors" do
      expect(Rails.logger).not_to receive(:error)
      run
    end

    it "calls command" do
      expect_any_instance_of(klass).to receive(:call)
      run
    end
  end

  context "when called with wrong class" do
    let(:klass) { WrongClass }

    it "logs error" do
      expect(Rails.logger).to receive(:error)
      run
    end
  end

  context "when command broadcasts :invalid", :aggregate_failures do
    it "logs error" do
      expect_any_instance_of(klass).to receive(:valid?).and_return(false)

      expect(Rails.logger).to receive(:error).twice
      run
    end
  end

  context "when command broadcasts :stale", :aggregate_failures do
    it "logs error" do
      expect_any_instance_of(klass).to receive(:stale?).and_return(true)

      expect(Rails.logger).to receive(:error).twice
      run
    end
  end

  context "when command broadcasts :aunauthorized" do
    it "logs error" do
      expect_any_instance_of(klass).to receive(:authorized?).and_return(false)

      expect(Rails.logger).to receive(:error).twice
      run
    end
  end

  context "when command broadcasts :aborted" do
    let(:klass) { AbortedCommand }

    it "logs error" do
      expect(Rails.logger).to receive(:error).twice
      run
    end
  end
end
