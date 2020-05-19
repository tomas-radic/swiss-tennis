module RequestsSpecHelper
  def requests_login(user, password)
    post sessions_path, params: { email: user.email, password: password }
  end
end
