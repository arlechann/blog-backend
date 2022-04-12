require 'sinatra'
require 'sinatra/reloader'
require 'json'

get '/' do
  'Hello world!'
end

get '/api/v1/ping' do
  JSON.generate(status: :success, message: :pong)
end
