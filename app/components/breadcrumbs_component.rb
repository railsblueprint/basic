class BreadcrumbsComponent < ViewComponent::Base
  include Turbo::FramesHelper
  include Loaf::ViewExtensions

  attr_accessor :_breadcrumbs

  def initialize(breadcrumbs)
    @_breadcrumbs = breadcrumbs
    super()
  end
end
