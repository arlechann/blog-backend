require 'sinatra'
require 'sinatra/reloader'
require 'uri'
require 'json'
require 'sequel'
require 'bcrypt'

def login_user
  session[:user_id]
end

def logged_in?
  login_user()
end

configure do
  enable :sessions
  #set :settions, expire_after: 60 * 60 * 24 * 30 # 1 month
  set :settions, expire_after: 60

  DB = Sequel.connect('postgres://postgres:password@db:5432/blog')
end

get '/' do
  'Hello world!'
end

get '/admin/' do
  redirect to('/admin/login') unless logged_in?
  'Logged-in!'
end

get '/admin/debug' do
  data = {
    'session' => session.to_s,
  }
  erb :'admin/debug', :locals => { data: data }
end

get '/admin/login' do
  redirect to('/admin/') if logged_in?
  default = { message: '', email: '' }
  erb :'admin/login', :locals => default.merge(params)
end

post '/admin/login' do
  email = params[:email]
  password = params[:password]

  failed_url = '/admin/login?' + URI.encode_www_form({ message: 'ログイン失敗', email: email })

  record = DB[<<~SQL, email: email].first
    SELECT administrators.id AS id, email, password
    FROM administrators
    JOIN administrator_secrets
      ON administrators.id = administrator_secrets.administrator_id
    WHERE email = :email
  SQL

  redirect to(failed_url) if record.nil?

  id = record[:id]
  email = record[:email]
  password_hash = record[:password].strip

  if BCrypt::Password.new(password_hash) == password
    session[:user_id] = id
    redirect to('/admin/')
  else
    redirect to(failed_url)
  end
end

get '/admin/logout' do
  session.delete(:admin_id)
  redirect to('/admin/login')
end

get '/api/v1/ping' do
  JSON.generate(status: :success, message: :pong)
end
