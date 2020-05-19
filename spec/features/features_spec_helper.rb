module FeaturesSpecHelper
  def features_login(user, password)
    visit login_path
    fill_in "email", with: user.email
    fill_in "password", with: password

    click_button "Potvrdiť"
  end
end
