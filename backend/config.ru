require_relative 'app'
require_relative 'lib/login'

DB = Sequel.connect('postgres://postgres:password@db:5432/blog')

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
  admin = DB[<<~SQL, email: email].first
    SELECT administrators.id AS id, email, password
    FROM administrators
    JOIN administrator_secrets
      ON administrators.id = administrator_secrets.administrator_id
    WHERE email = :email
  SQL
  return nil if admin.nil?
  admin[:user_id] = admin[:email]
  admin
end

run App

