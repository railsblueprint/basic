# allows to easily match errors when testing commands
# Example:
#
#   class SomeCommand < BaseCommand
#     attribute :bar, Types::String
#
#     validate :bar_value
#
#     def process
#     end
#
#     def bar_value
#       return if bar == "bar"
#       errors.add(:bar, invalid)
#     end
#   end
#
#   RSpec.describe SomeCommand, type: :command do
#     subject { described_class.new(params) }
#     let(:params) { { foo: 'bar' } }
#
#     it "should broadcast invalid" do
#       expect { subject.call }.to broadcast :invalid, errors_exactly(
#         bar: :invalid
#       )
#     end
#   end
#
# errors_exactly expects exact match of errors.
# errors_including ignores additional errors.
#
# Ways to specify errors:
#
# errors_including({
#                    attribute: :type,
#                    attribite2: [:type2, :type3],
#                    attribite3: {type: :type4, message: "message"},
#                    attribite4: [:type5, {type: :type6, message: "message"}],
#                  })

RSpec::Matchers.define :errors_including do |list|
  match do |errors|
    errors.is_a?(ActiveModel::Errors) && list.all? { |key, values|
      values = [{ type: values }] if values.is_a?(Symbol) || values.is_a?(Hash)
      values.map! { |value| value.is_a?(Symbol) ? { type: value } : value }
      values.all? { |value|
        errors.errors.any? { |e|
          e.attribute == key &&
          e.type == value[:type] &&
          (value[:message].blank? || e.message == value[:message])
        }
      }
    }
  end
  description do
    "ActiveModel::Errors including #{list.inspect}"
  end
end

RSpec::Matchers.define :errors_exactly do |list|
  match do |errors|
    errors.is_a?(ActiveModel::Errors) && list.all? { |key, values|
      values = [{ type: values }] if values.is_a?(Symbol) || values.is_a?(Hash)
      values.map! { |value| value.is_a?(Symbol) ? { type: value } : value }
      values.all? { |value|
        errors.errors.any? { |e|
          e.attribute == key &&
          e.type == value[:type] &&
          (value[:message].blank? || e.message == value[:message])
        }
      }
    } && errors.errors.count == list.values.flatten.count
  end
  description do
    "ActiveModel::Errors including exactly #{list.inspect}"
  end
end
