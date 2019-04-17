namespace :data do
  desc "Creates default users"
  task create_users: :environment do
    %w{tomas.radic@gmail.com ondrejemilbabala@gmail.com}.each do |email|
      user = User.find_by(email: email)

      if user.nil?
        puts "Creating #{email} ..."
        User.create!(email: email, password: 'nbusr123')
      else
        puts "#{email} already exists"
      end
    end

    puts 'Done.'
  end

  desc "Creates default categories"
  task create_categories: :environment do
    %w{60r+ 50r+ Registrovaný Neregistrovaný}.each do |category|
      puts "Creating #{category} ..."
      Category.where(name: category).first_or_create!
    end

    puts 'Done.'
  end

  desc "Creates default seasons"
  task create_seasons: :environment do
    %w{2019}.each do |season|
      puts "Creating #{season} ..."
      Season.where(name: season).first_or_create!
    end

    puts 'Done.'
  end
end
