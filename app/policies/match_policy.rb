class MatchPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.present?
        scope.all
      else
        PublishedMatchesQuery.call
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
    user.present?
  end

  def finish?
    user.present? && match_not_finished?
  end

  def swap_players?
    user.present? && match_not_finished?
  end

  private

  def match_not_finished?
    !record.finished?
  end
end
