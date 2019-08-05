class Article < ApplicationRecord
  RECENT_PERIOD = 5.days

  belongs_to :user
  belongs_to :season

  validates :title,
            :content,
            presence: true

  scope :sorted, -> { order(created_at: :desc) }
  scope :published, -> { where(published: true) }
  scope :draft, -> { where(published: false) }
end
