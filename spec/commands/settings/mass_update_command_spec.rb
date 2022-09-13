describe Settings::MassUpdateCommand, type: :command do
  subject { described_class.new(settings: params, current_user: admin).no_exceptions! }

  let(:admin) { create(:user, :superadmin) }
  let(:settings) { create_list(:setting, 3) }

  let(:params) {
    {
      settings[0].id => { value: "value1" },
      settings[1].id => { value: "value2" },
      settings[2].id => { value: "value3" }
    }
  }

  context "with invalid params" do
    let(:params) {
      {
        "123" => { value: "value1" }
      }
    }

    it "broadcasts invalid" do
      expect { subject.call }.to broadcast :invalid, errors_exactly(
        base: :invalid_id
      )
    end
  end

  context "with valid params" do
    it "broadcasts ok" do
      expect { subject.call }.to broadcast(:ok)
    end

    it "updates setting attributes", :aggregate_failures do
      subject.call
      expect(settings[0].reload.value).to eq("value1")
      expect(settings[1].reload.value).to eq("value2")
      expect(settings[2].reload.value).to eq("value3")
    end
  end

  context "when not enough premissions" do
    let(:admin) { create(:user) }

    it "broadcasts unauthorized" do
      expect { subject.call }.to broadcast(:unauthorized)
    end
  end
end
