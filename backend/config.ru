require_relative 'app'
require_relative 'lib/db'
require_relative 'lib/session_login/login'
require_relative 'repository/login_user_repository'

use Rack::Session::Cookie,
  expire_after: 30 * 24 * 60 * 60, # 30 days
  secret: ''

use Rack::Protection

use SessionLogin, {
  login_path: '/admin/login',
  logout_path: '/admin/logout',
  success_path: '/admin/',
  form_login_id_key: 'email',
  failed_message: 'ログイン失敗',
} do |email|
  login_user_repo = LoginUserRepository.new(DB)
  login_user_repo.find_by_email(email).to_h
end

run App
