module AuthenticationHelpers
  def login(user, password)
    post sessions_path, params: { email: user.email, password: password }
  end
end
