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
    user.present? && update?
  end

  def update?
    user.present? && match_not_finished?
  end

  def destroy?
    user.present? && match_not_finished?
  end

  def finish?
    user.present? && match_not_finished?
  end

  private

  def match_not_finished?
    !record.finished?
  end
end
