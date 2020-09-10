class Round < ApplicationRecord
  belongs_to :season
  has_many :matches, dependent: :restrict_with_error
  has_many :rankings, dependent: :restrict_with_error
  has_many :players, through: :rankings

  acts_as_list scope: :season

  scope :default, -> { order(position: :desc) }
  scope :regular, -> { where(specific_purpose: false) }

  def full_label
    if label.blank?
      "Kolo #{position}"
    else
      label
    end
  end
end
