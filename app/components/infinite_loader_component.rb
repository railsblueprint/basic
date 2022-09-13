class InfiniteLoaderComponent < ViewComponent::Base
  attr_reader :visible

  def initialize(visible: false)
    super
    @visible = visible
  end
end
