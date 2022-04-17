require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'time'

require_relative 'lib/db'
require_relative 'lib/login'
require_relative 'error/http'
require_relative 'use_case/post/create_post_use_case'
require_relative 'use_case/post/update_post_use_case'
require_relative 'repository/administrator_repository'
require_relative 'repository/post_repository'
require_relative 'repository/publish_status_repository'

class App < Sinatra::Application
  session_login

  helpers do
    alias_method :h, :escape_html
  end

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
    
    post_repo = PostRepository.new(DB)
    ps_repo = PublishStatusRepository.new(DB)
    admin_repo = AdministratorRepository.new(DB)
    administrator_id = session[:user_id][:id]

    posts = post_repo.all
    publish_statuses = ps_repo.all
    administrators = admin_repo.all

    @title = '投稿一覧'
    erb :'admin/post/index', :locals => {
      administrator_id: administrator_id,
      posts: posts,
      publish_statuses: publish_statuses,
      administrators: administrators,
    }
  end

  get '/admin/post/add' do
    redirect to('/admin/') unless login?

    ps_repo = PublishStatusRepository.new(DB)
    publish_statuses = ps_repo.all

    @title = '投稿作成'
    erb :'admin/post/add', :locals => { post: nil, publish_statuses: publish_statuses }
  end

  post '/admin/post/add' do
    redirect to('/admin/') unless login?

    input = CreatePostUseCase::InputPort.new(
      title: params[:title] || '',
      content: params[:content] || '',
      publish_status_id: params[:publish_status],
      administrator_id: session[:user_id][:id],
    )

    output = Proc.new do |post|
      post_id = post.id
      redirect to('/admin/post/add') if post_id.nil?
      redirect to('/admin/post')
    end

    CreatePostUseCase
      .new(input, output, PostRepository.new(DB))
      .process
  end

  get '/admin/post/edit/:id' do
    redirect to('/admin/') unless login?

    post_repo = PostRepository.new(DB)
    ps_repo = PublishStatusRepository.new(DB)
    post_id = params[:id]
    administrator_id = session[:user_id][:id]

    post = post_repo.find_by_id(post_id)
    redirect to('/admin/post') unless post.administrator_id == administrator_id
    publish_statuses = ps_repo.all

    @title = '投稿編集'
    erb :'admin/post/add', :locals => { post: post, publish_statuses: publish_statuses }
  end

  post '/admin/post/edit/:id' do
    redirect to('/admin/') unless login?

    input = UpdatePostUseCase::InputPort.new(
      id: params[:id],
      title: params[:title] || '',
      content: params[:content] || '',
      publish_status_id: params[:publish_status],
    )

    output = Proc.new do |post, updated_row_count|
      post_id = post.id
      redirect to(`/admin/post/edit/#{post_id}`) if updated_row_count.zero?
      redirect to('/admin/post')
    end

    UpdatePostUseCase
      .new(input, output, PostRepository.new(DB))
      .process
  end

  post '/admin/post/delete/:id' do
    redirect to('/admin/') unless login?

    post_repo = PostRepository.new(DB)
    post_id = params[:id]
    administrator_id = session[:user_id][:id]
    post = post_repo.find_by_id(post_id)
    raise HTTPError::Forbidden unless post.administrator_id == administrator_id
    deleted_row = post_repo.delete_by_id(post_id)
    redirect to('/admin/post')
  end

  get '/api/v1/ping' do
    JSON.generate(status: :success, message: :pong)
  end

  error HTTPError::Forbidden do
    "<h1>403 Forbidden</h1>"
  end
end

