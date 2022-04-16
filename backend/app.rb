require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'sequel'

require_relative 'lib/login'

class App < Sinatra::Application
  session_login
  
  get '/' do
    'Hello world!'
  end
  
  get '/admin/' do
    redirect to('/admin/login') unless login?

    @title = 'トップ'
    erb :'admin/index'
  end
  
  get '/admin/debug' do
    data = {
      'session' => session.inspect,
    }

    @title = 'デバッグ'
    erb :'admin/debug', :locals => { data: data }
  end
  
  get '/admin/login' do
    redirect to('/admin/') if login?

    @title = 'ログイン'
    default = { message: '', email: '' }
    erb :'admin/login', :locals => default.merge(params)
  end
  
  get '/api/v1/ping' do
    JSON.generate(status: :success, message: :pong)
  end
end

