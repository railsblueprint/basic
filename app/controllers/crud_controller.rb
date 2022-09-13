class CrudController < ApplicationController
  include CrudBase
  include CrudAuthorization

  def paginate(collection)
    pagy(collection)
  end

  def actions_with_resource
    base_actions_with_resource
  end

  private

  def context
    {
      id:           @resource&.id,
      current_user:
    }
  end
end
