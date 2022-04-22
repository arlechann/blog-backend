require 'rack'
require 'uri'
require 'bcrypt'

class Sinatra::Base
  def self.session_login_utils(session_key = 'user_id')
    define_method(:login_user_id) do
      self.session[session_key]
    end

    define_method(:login?) do
      login_user_id
    end
  end
end

module Rack
  class SessionLogin
    def initialize(app, config = {}, &block)
      config = config_defaults.merge(config)

      @app = app
      @login_path = config[:login_path]
      @logout_path = config[:logout_path]
      @success_path = config[:success_path]
      @form_login_id_key = config[:form_login_id_key]
      @form_password_key = config[:form_password_key]
      @session_key = config[:session_key]
      @failed_message = config[:failed_message]
      @user_info_proc = block
    end

    def config_defaults
      {
        login_path: '/login',
        logout_path: '/logout',
        success_path: '/',
        form_login_id_key: 'username',
        form_password_key: 'password',
        session_key: 'user_id',
        failed_message: 'Fail to login.',
      }
    end

    def call(env)
      req = Rack::Request.new(env)
      if req.post? && req.path_info == @login_path
        post_login(req)
      elsif req.path_info == @logout_path
        any_logout(req)
      else
        @app.call(req.env)
      end
    end

    def post_login(req)
      form_data = URI.decode_www_form(req.body.read).to_h
      login_id = form_data[@form_login_id_key]
      password = form_data[@form_password_key]
      is_success = login(req, login_id, password)
      login_succeeded if is_success
      login_failed
    end

    def login(req, login_id, password)
      return false if login_id.nil? || password.nil?
      user = user_info(login_id)
      return false if user.nil?
      is_verified = verify_password(user[:password], password)
      return false unless is_verified
      save_id(req, user[:id])
    end

    def login_succeeded
      redirect(@success_path)
    end

    def login_failed
      redirect(@login_path + '?' + URI.encode_www_form({ message: @failed_message }))
    end

    def verify_password(hash, password)
      hash && password && BCrypt::Password.new(hash) == password
    end

    def user_info(login_id)
      login_id && @user_info_proc.call(login_id)
    end

    def save_id(req, user_id)
      req.session[@session_key] = user_id
    end

    def any_logout(req)
      logout(req)
      redirect(@login_path)
    end

    def logout(req)
      req.session.delete(@session_key)
      true
    end

    def redirect(path)
      [302, { 'Location' => path }, []]
    end
  end
end
