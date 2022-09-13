class ApplicationPolicy
  attr_reader :user, :resource

  def initialize(user, resource)
    @user = user
    @resource = resource
  end

  def scope
    Pundit.policy_scope!(user, resource.class)
  end

  # enable default view actions
  # viewing list typically enables to view single object
  def index? = true
  def show? = index?

  # create and update operations have two different controllers actions,
  # but typically should have the same permissions
  def create? = new?
  def update? = edit?

  # enable everything for admin and superadmin users
  # disable everything else by default
  def method_missing(_name)
    @user&.admin? || @user&.superadmin?
  end

  def respond_to_missing?(...)
    true
  end

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      scope.all
    end
  end
end
