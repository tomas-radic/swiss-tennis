class Player < ApplicationRecord
  belongs_to :category

  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validates :first_name,
            :last_name,
            presence: true
end
