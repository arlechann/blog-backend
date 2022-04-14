require 'sinatra'
require 'sinatra/reloader'
require 'uri'
require 'json'
require 'sequel'
require 'bcrypt'

require_relative 'lib/login'

DB = Sequel.connect('postgres://postgres:password@db:5432/blog')

use Rack::Session::Cookie,
  expire_after: 30 * 24 * 60 * 60, # 30 days
  secret: ''

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
  admin['user_id'] = admin['email'] unless admin.nil?
  admin
end

class App < Sinatra::Application
  session_login
  
  get '/' do
    'Hello world!'
  end
  
  get '/admin/' do
    redirect to('/admin/login') unless login?
    'Logged-in!'
  end
  
  get '/admin/debug' do
    data = {
      'session' => session.to_s,
    }
    erb :'admin/debug', :locals => { data: data }
  end
  
  get '/admin/login' do
    redirect to('/admin/') if login?
    default = { message: '', email: '' }
    erb :'admin/login', :locals => default.merge(params)
  end
  
  get '/api/v1/ping' do
    JSON.generate(status: :success, message: :pong)
  end

  run! if app_file == $0
end

