class Player < ApplicationRecord

  before_validation :normalize_phone

  belongs_to :category
  has_many :match_assignments, dependent: :restrict_with_error
  has_many :matches, through: :match_assignments
  has_many :player1_matches, class_name: 'Match', foreign_key: :player1_id
  has_many :player2_matches, class_name: 'Match', foreign_key: :player2_id
  has_many :won_matches, class_name: 'Match', foreign_key: :winner_id
  has_many :lost_matches, class_name: 'Match', foreign_key: :looser_id
  has_many :rankings, dependent: :restrict_with_error
  has_many :rounds, through: :rankings
  has_many :enrollments, dependent: :restrict_with_error
  has_many :seasons, through: :enrollments

  validates :email,
            format: { with: URI::MailTo::EMAIL_REGEXP },
            uniqueness: true,
            allow_blank: true
  validates :phone,
            numericality: true,
            length: { is: 10 },
            uniqueness: true,
            allow_blank: true
  validates :first_name,
            :last_name,
            presence: true

  scope :default, -> { active.where(dummy: false) }
  scope :active, -> { where(active: true) }


  has_paper_trail on: [:update], only: [:first_name, :last_name, :category_id]


  def name
    [first_name, last_name].join(' ')
  end


  def normalize_phone
    phone.gsub!(/\s/, '') if phone
  end


  def opponents_in(season)
    Player.joins(matches: :round)
          .where("rounds.season_id = ?", season.id)
          .where("matches.player1_id = ? or matches.player2_id = ?", id, id)
          .where("players.id != ?", id).distinct
  end
end
