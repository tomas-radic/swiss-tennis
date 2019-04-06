namespace :data do
  desc "TODO"
  task create_users: :environment do
    %w{tomas.radic@gmail.com ondrejemilbabala@gmail.com}.each do |email|
      user = User.find_by(email: email)

      if user.nil?
        puts "Creating #{email}..."
        User.create!(email: email, password: 'nbusr123')
      else
        puts "#{email} already exists"
      end
    end

    puts 'Done.'
  end

end
