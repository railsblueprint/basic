class ToastrFlashComponent < ViewComponent::Base
  attr_accessor :append

  def initialize(append: false)
    super
    @append = append
  end

  # rubocop:disable Style/DocumentDynamicEvalDefinition
  def capture_to_local(var, &block)
    # sets local variable to caller's context
    set_var = block.binding.eval("lambda {|x| #{var} = x }")
    set_var.call(capture(&block))
  end
  # rubocop:enable Style/DocumentDynamicEvalDefinition
end
