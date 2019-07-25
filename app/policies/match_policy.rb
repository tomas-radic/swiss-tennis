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

  def new?
   create?
  end

  def create?
   user.present?
  end

  def destroy?
    match_not_finished?
  end

  def finish?
    match_not_finished?
  end

  def swap_players?
    match_not_finished?
  end

  private

  def match_not_finished?
    !record.finished?
  end
end
