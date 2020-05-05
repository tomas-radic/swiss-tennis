class EnrollmentsController < ApplicationController
  before_action :verify_user_logged_in, except: [:index]
  before_action :load_unenrolled_players, only: [:new, :create]

  def index
    @most_recent_article = MostRecentArticlesQuery.call(season: selected_season).first
    @enrollments = selected_season.enrollments.active
                       .joins(player: :category)
                       .where(players: { dummy: false })
                       .order('enrollments.created_at desc')
                       .order('categories.name')
                       .order('players.last_name')
                       .includes(player: :category)
  end

  def new
    @enrolling_existing_player = true
    @enrollment = selected_season.enrollments.new
    @player = Player.new
  end

  def create
    @enrolling_existing_player = enrolling_existing_player?

    if @enrolling_existing_player
      @enrollment = EnrollPlayerToSeason.call(
                        whitelisted_params.to_h.dig(:enrollment, :player_id),
                        selected_season
      ).result

      if @enrollment.persisted?
        redirect_to enrollments_path, notice: true
      else
        @player = Player.new
        render :new
      end
    else
      ActiveRecord::Base.transaction do
        @player = Player.create(new_player_params)

        if @player.persisted?
          EnrollPlayerToSeason.call(@player.id, selected_season)
          redirect_to enrollments_path, notice: true
        else
          @enrollment = selected_season.enrollments.new(
              player_id: whitelisted_params.to_h.dig(:enrollment, :player_id))

          render :new
        end
      end
    end
  end

  def cancel
    @enrollment = Enrollment.find(params[:id])
    @enrollment.update!(canceled: true)

    redirect_to enrollments_path, notice: true
  end

  private

  def enrolling_existing_player?
    params[:enrollment].present?
  end

  def load_unenrolled_players
    @unenrolled_players = Player.default
                              .where.not(id: selected_season.enrollments.active.pluck(:player_id))
                              .order(:last_name)
  end

  def whitelisted_params
    params.permit(enrollment: [:player_id])
  end

  def new_player_params
    @first_name = params[:first_name]
    @last_name = params[:last_name]
    @phone = params[:phone]
    @email = params[:email]
    @birth_year = params[:birth_year]
    @category_id = params[:category_id]
    @consent_given = params[:consent_given] == '1'

    {
        first_name: @first_name,
        last_name: @last_name,
        phone: @phone,
        email: @email,
        birth_year: @birth_year,
        category_id: @category_id,
        consent_given: @consent_given
    }.reject { |key, value| value.nil? }
  end
end
