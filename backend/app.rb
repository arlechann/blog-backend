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
end

