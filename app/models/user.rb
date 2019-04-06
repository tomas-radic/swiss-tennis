class User < ApplicationRecord

  has_secure_password

  validates :email,
            presence: true,
            uniqueness: true,
            format: /\A[^@\s]+@([^@\s]+\.)+[^@\s]+\z/
  validates :password, length: { minimum: 6 }, allow_nil: true
end
