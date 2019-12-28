class Payment < ApplicationRecord
  before_validation :set_text_amount

  validates :amount,
            :text_amount,
            :paid_on, presence: true

  scope :sorted, -> { order(paid_on: :desc) }

  private

  def set_text_amount
    return if self.amount.nil?
    self.text_amount = "#{amount / 100.0}€"
  end
end
