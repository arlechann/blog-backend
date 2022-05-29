require 'rack/cors'
require_relative 'app'
require_relative 'lib/db'
require_relative 'lib/session_login/login'
require_relative 'repository/login_user_repository'

use Rack::Session::Cookie,
  expire_after: 30 * 24 * 60 * 60, # 30 days
  secret: ''

use Rack::Protection

use Rack::Cors do
  allow do
    origins /localhost(:[0-9]+)?/
    resource '/api/v1/*',
      headers: :any,
      methods: :get
  end
end

use Rack::SessionLogin, {
  form_login_id_key: 'email',
  failed_message: 'ログイン失敗',
} do |email|
  login_user_repo = LoginUserRepository.new(DB)
  login_user_repo.find_by_email(email).to_h
end

run App
