require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'time'

require_relative 'lib/db'
require_relative 'lib/login'
require_relative 'model/post'

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
    
    administrator_id = session[:user_id][:id]
    posts = Database.new().all_posts

    @title = '投稿一覧'
    erb :'admin/post/index', :locals => { administrator_id: administrator_id, posts: posts }
  end

  get '/admin/post/add' do
    redirect to('/admin/') unless login?

    publish_statuses = Database.new().all_publish_statuses

    @title = '投稿作成'
    erb :'admin/post/add', :locals => { post: nil, publish_statuses: publish_statuses }
  end

  post '/admin/post/add' do
    redirect to('/admin/') unless login?

    post = Post.new(
      title: params[:title] || '',
      content: params[:content] || '',
      publish_status_id: params[:publish_status],
      administrator_id: session[:user_id][:id],
    )
    pk = Database.new().insert_post(post)
    redirect to('/admin/post/add') if pk.nil?
    redirect to('/admin/post')
  end

  get '/admin/post/edit/:id' do
    redirect to('/admin/') unless login?

    post_id = params[:id]
    administrator_id = session[:user_id][:id]
    db = Database.new()
    post = db.find_post_by_id(post_id)
    redirect to('/admin/post') unless post.administrator_id == administrator_id
    publish_statuses = db.all_publish_statuses

    @title = '投稿編集'
    erb :'admin/post/add', :locals => { post: post, publish_statuses: publish_statuses }
  end

  post '/admin/post/edit/:id' do
    redirect to('/admin/') unless login?

    post_id = params[:id]
    administrator_id = session[:user_id][:id]
    db = Database.new()
    post = db.find_post_by_id(post_id)
    return [403, {}, '<h1>Forbidden</h1>'] unless post.administrator_id == administrator_id
    post.update_title(params[:title] || '')
    post.update_content(params[:content] || '')
    post.update_publish_status_id(params[:publish_status])
    updated_row = db.update_post(post)
    redirect to(`/admin/post/edit/#{post_id}`) if updated_row.zero?
    redirect to('/admin/post')
  end

  post '/admin/post/delete/:id' do
    redirect to('/admin/') unless login?

    post_id = params[:id]
    administrator_id = session[:user_id][:id]
    db = Database.new()
    post = db.find_post_by_id(post_id)
    return [403, {}, '<h1>Forbidden</h1>'] unless post.administrator_id == administrator_id
    deleted_row = db.delete_post_by_id(post_id)
    redirect to('/admin/post')
  end

  get '/api/v1/ping' do
    JSON.generate(status: :success, message: :pong)
  end
end

