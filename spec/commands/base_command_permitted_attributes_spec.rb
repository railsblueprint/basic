describe BaseCommand do
  describe ".permitted_attributes" do
    before do
      stub_const("CommandWithArrayAttributes",
                 Class.new(BaseCommand) do
                   attribute :name, BaseCommand::Types::String
                   attribute :tags, BaseCommand::Types::Array
                   attribute :role_ids, BaseCommand::Types::Array
                   attribute :active, BaseCommand::Types::Bool
                   attribute :metadata, BaseCommand::Types::Hash
                   attribute :count, BaseCommand::Types::Integer
                   attribute :items, BaseCommand::Types::Array

                   def process; end
                 end)
    end

    context "with mixed attribute types" do
      subject { CommandWithArrayAttributes.permitted_attributes }

      it "returns proper format for array attributes" do
        expect(subject).to include({ tags: [] })
        expect(subject).to include({ role_ids: [] })
        expect(subject).to include({ items: [] })
      end

      it "returns simple symbols for non-array attributes" do
        expect(subject).to include(:name)
        expect(subject).to include(:active)
        expect(subject).to include(:count)
      end

      it "returns proper format for hash attributes" do
        expect(subject).to include(:metadata)
      end

      it "does not duplicate attribute names" do
        names = subject.map { |attr| attr.is_a?(Hash) ? attr.keys.first : attr }
        expect(names.uniq.size).to eq(names.size)
      end
    end

    context "with command that has no array attributes" do
      subject { SimpleCommand.permitted_attributes }

      before do
        stub_const("SimpleCommand",
                   Class.new(BaseCommand) do
                     attribute :name, BaseCommand::Types::String
                     attribute :age, BaseCommand::Types::Integer

                     def process; end
                   end)
      end

      it "returns only simple attribute names" do
        expect(subject).to eq([:name, :age])
      end
    end

    context "when using with ActionController::Parameters" do
      before do
        stub_const("TestCommand",
                   Class.new(BaseCommand) do
                     attribute :title, BaseCommand::Types::String
                     attribute :tag_ids, BaseCommand::Types::Array

                     def process; end
                   end)
      end

      let(:params) do
        ActionController::Parameters.new({
          test_command: {
            title:       "Test",
            tag_ids:     ["1", "2", ""],
            extra_field: "ignored"
          }
        })
      end

      it "properly permits array parameters" do
        attributes = TestCommand.attributes_from_params(params)
        expect(attributes[:title]).to eq("Test")
        expect(attributes[:tag_ids]).to eq(["1", "2", ""])
        expect(attributes).not_to have_key(:extra_field)
      end
    end

    context "inheritance" do
      subject { ChildCommand.permitted_attributes }

      before do
        stub_const("ParentCommand",
                   Class.new(BaseCommand) do
                     attribute :name, BaseCommand::Types::String
                     attribute :tags, BaseCommand::Types::Array

                     def process; end
                   end)
        stub_const("ChildCommand",
                   Class.new(ParentCommand) do
                     attribute :extra_ids, BaseCommand::Types::Array
                     attribute :status, BaseCommand::Types::String
                   end)
      end

      it "includes parent attributes with proper format" do
        expect(subject).to include(:name)
        expect(subject).to include({ tags: [] })
      end

      it "includes child attributes with proper format" do
        expect(subject).to include({ extra_ids: [] })
        expect(subject).to include(:status)
      end
    end
  end
end
