class HttpRequest < ApplicationRecord

  # Validations ---------------- #
  validates :path, :year, :week, :ip_address, :count,
            presence: true
  validates :path, uniqueness: { scope: [:year, :week, :ip_address] }

end
