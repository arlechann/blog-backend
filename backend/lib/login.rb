require 'rack'
require 'uri'
require 'bcrypt'

class Sinatra::Base
  def self.session_login(user_id = :user_id)
    define_method(:login_user) do
      self.session[user_id]
    end

    define_method(:login?) do
      login_user
    end
  end
end

class SessionLogin
  attr_reader :app, :login_path, :logout_path, :success_path, :login_id_key, :password_key, :form_login_id_key, :form_password_key, :session_key, :user_pk, :failed_message, :user_info_proc

  def initialize(app, config = {}, &block)
    @app = app
    @login_path = config[:login_path] || '/login'
    @logout_path = config[:logout_path] || '/logout'
    @success_path = config[:success_path] || '/'
    @form_login_id_key = config[:form_login_id_key] || 'username'
    @form_password_key = config[:form_password_key] || 'password'
    @session_key = config[:session_key] || 'user_id'
    @user_pk = config[:user_pk] || 'id'
    @failed_message = config[:failed_message] || 'Fail to login.'
    @user_info_proc = block
  end

  def call(env)
    req = Rack::Request.new(env)
    if req.post? && req.path_info == login_path
      post(req)
    elsif req.path_info == logout_path
      logout(req)
    else
      app.call(req.env)
    end
  end

  def post(req)
    form_data = URI.decode_www_form(req.body.read).to_h
    login_id = form_data[form_login_id_key]
    password = form_data[form_password_key]
    user = login(login_id, password)
    return login_failed if user.nil?
    save_id(req, user)
    login_succeeded
  end

  def login(login_id, password)
    return false if login_id.nil? || password.nil?
    user = user_info(login_id)
    return false if user.nil?
    is_verified = verify_password(user[:password], password)
    return false unless is_verified
    user
  end

  def login_succeeded
    redirect(success_path)
  end

  def login_failed
    redirect(login_path + URI.encode_www_form({ message: failed_message }))
  end

  def verify_password(hash, password)
    hash && password && BCrypt::Password.new(hash) == password
  end

  def user_info(login_id)
    login_id && user_info_proc.call(login_id)
  end

  def save_id(req, user_id)
    req.session[session_key] = user_id
  end

  def logout(req)
    req.session.delete(session_key)
    redirect(login_path)
  end

  def redirect(path)
    [302, { 'Location' => path }, []]
  end
end
