require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'time'

require_relative 'lib/db'
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

  get '/admin/post' do
    redirect to('/admin/') unless login?

    posts = Database.new().all_posts

    @title = '投稿一覧'
    erb :'admin/post/index', :locals => { posts: posts }
  end

  get '/admin/post/add' do
    redirect to('/admin/') unless login?

    publish_statuses = Database.new().all_publish_statuses

    @title = '投稿作成'
    erb :'admin/post/add', :locals => { publish_statuses: publish_statuses }
  end

  post '/admin/post/add' do
    redirect to('/admin/') unless login?

    post = {
      title: params[:title] || '',
      content: params[:content] || '',
      publish_status_id: params[:publish_status],
      administrator_id: session[:user_id][:id],
      created_at: Time.now.iso8601,
      last_updated_at: Time.now.iso8601,
    }
    pk = Database.new().insert_post(post)
    redirect to('/admin/post/add') if pk.nil?
    redirect to('/admin/post')
  end

  post '/admin/post/delete/:id' do
    redirect to('/admin/') unless login?

    post_id = params[:id]
    Database.new().delete_post_by_id(post_id)
    redirect to('/admin/post')
  end

  get '/api/v1/ping' do
    JSON.generate(status: :success, message: :pong)
  end
end

