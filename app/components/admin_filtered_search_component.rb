class AdminFilteredSearchComponent < ViewComponent::Base
  attr_accessor :fields

  def initialize(fields: [])
    super
    @fields = fields
  end
end
