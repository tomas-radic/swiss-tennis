class User < ApplicationRecord
  has_secure_password

  validates :email,
            presence: true,
            uniqueness: true,
            format: /\A[^@\s]+@([^@\s]+\.)+[^@\s]+\z/
  validates :password, length: { minimum: 6 }, allow_nil: true

  cattr_reader :current_password

  def update_with_password(user_params)
    current_password = user_params.delete(:current_password)

    if self.authenticate(current_password)
      self.update(user_params)
      true
    else
      self.errors.add(:current_password, current_password.blank? ? :blank : :invalid)
      false
    end
  end
end
