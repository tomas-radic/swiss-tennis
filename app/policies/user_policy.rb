class UserPolicy < ApplicationPolicy
  def update?
    record == user
  end

  def edit
    update?
  end
end
