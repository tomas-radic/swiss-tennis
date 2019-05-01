class MatchPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.present?
        scope.all
      else
        scope.published
      end
    end
  end

  def edit?
    update?
  end

  def update?
    !record.finished?
  end

  def destroy?
    update?
  end
end
