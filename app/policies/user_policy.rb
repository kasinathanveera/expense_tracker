class UserPolicy < ApplicationPolicy
  def create?
    user.id == record.id && user.active?
  end

  def access_enabled?
    user.admin? || user.id == record.id
  end
end
