class Payment < ApplicationRecord
  include ApplicationHelper
  
  before_validation :set_text_amount

  validates :amount,
            :text_amount,
            :paid_on, presence: true

  scope :sorted, -> { order(paid_on: :desc) }

  private

  def set_text_amount
    return if amount.nil?
    self.text_amount = currency_string(amount)
  end
end
