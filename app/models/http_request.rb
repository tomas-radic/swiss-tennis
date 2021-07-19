class HttpRequest < ApplicationRecord

  # Validations ---------------- #
  validates :path, :year, :week, :count,
            presence: true
  validates :path, uniqueness: { scope: [:year, :week] }

end
