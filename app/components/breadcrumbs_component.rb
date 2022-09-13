class BreadcrumbsComponent < ViewComponent::Base
  include Turbo::FramesHelper
  include Loaf::ViewExtensions

  attr_accessor :_breadcrumbs

  def initialize(breadcrumbs)
    super
    @_breadcrumbs = breadcrumbs
  end
end
