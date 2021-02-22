class Round < ApplicationRecord
  belongs_to :season
  has_many :matches, dependent: :destroy
  has_many :finished_matches, -> { where("matches.finished_at is not null") }, class_name: "Match"
  has_many :rankings, dependent: :destroy
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
