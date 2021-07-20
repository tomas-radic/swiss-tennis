namespace :data do

  desc "Creates default users"
  task create_users: :environment do
    %w{tomas.radic@gmail.com ondrejemilbabala@gmail.com}.each do |email|
      user = User.find_by(email: email)

      if user.nil?
        puts "Creating #{email} ..."
        User.create!(email: email, password: 'password')
      else
        puts "#{email} already exists"
      end
    end

    puts 'Done.'
  end


  desc "Creates default categories"
  task create_categories: :environment do
    categories = [
      { name: "Neregistrovaní", nr_finalists: 2, detail: "aj registrovaní hráči, ktorí sa registrovali až vo veku viac ako 18 rokov" },
      { name: "Registrovaní", nr_finalists: 2, detail: "aj bývalí registrovaní, ktorí mali registráciu vo veku do 18 rokov" },
      { name: "Ženy", nr_finalists: 2 },
      { name: "50r+", nr_finalists: 2 },
      { name: "60r+", nr_finalists: 2 }
    ]

    categories.each do |category|
      puts "Creating #{category[:name]} ..."
      record = Category.where(name: category[:name]).first_or_initialize
      record.detail = category[:detail]
      record.save!
    end

    puts 'Done.'
  end
end
