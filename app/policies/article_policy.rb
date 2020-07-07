class ArticlePolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.present?
        scope.all
      else
        scope.published
      end
    end
  end

  def show?
    available?
  end

  def load_content?
    available?
  end

  private

  def available?
    user.present? || record.published?
  end
end
