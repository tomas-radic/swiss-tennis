class CreateSeason < Patterns::Service
  pattr_initialize :season_name

  def call
    puts "Creating season '#{season_name}' ..."

    ActiveRecord::Base.transaction do
      season = Season.create!(name: season_name)
      dummy_player = Player.where(dummy: true).first_or_create!(first_name: 'Večný', last_name: 'Looser', category: Category.first)
      Enrollment.create!(season: season, player: dummy_player)
    end

    puts 'Done.'
  end
end
