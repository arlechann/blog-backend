require_relative 'app'
require_relative 'lib/db'
require_relative 'lib/login'

use Rack::Session::Cookie,
  expire_after: 30 * 24 * 60 * 60, # 30 days
  secret: ''

use Rack::Protection

use SessionLogin, {
  login_path: '/admin/login',
  logout_path: '/admin/logout',
  success_path: '/admin/',
  login_id_key: 'email',
  form_login_id_key: 'email',
  failed_message: 'ログイン失敗',
} do |email|
  admin = Database.new().find_administrator_by_email(email)
  return nil if admin.nil?
  admin[:user_id] = admin[:email]
  admin
end

run App

