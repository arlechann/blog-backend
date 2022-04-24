require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'time'

require_relative 'lib/db'
require_relative 'lib/session_login/login'
require_relative 'error/http'
require_relative 'use_case/post/list_post_use_case'
require_relative 'use_case/post/show_post_use_case'
require_relative 'use_case/post/create_post_use_case'
require_relative 'use_case/post/update_post_use_case'
require_relative 'use_case/post/delete_post_use_case'
require_relative 'repository/administrator_repository'
require_relative 'repository/post_repository'
require_relative 'repository/publish_status_repository'

class App < Sinatra::Application
  session_login_utils

  helpers do
    alias_method :h, :escape_html
  end

  before do
    without_login_paths = ['/login', '/debug']
    return if request.path_info.start_with?('/api') || without_login_paths.include?(request.path_info)

    user_id = login_user_id
    redirect to('/login') if user_id.nil?
    @user = AdministratorRepository.new(DB).find_by_id(user_id)
  end

  get '/' do
    @title = 'トップ'
    erb :'index'
  end
  
  get '/debug' do
    data = {
      'session' => session.inspect,
    }

    @title = 'デバッグ'
    erb :'debug', :locals => { data: data }
  end
  
  get '/login' do
    redirect to('/') if login?

    @title = 'ログイン'
    default = { message: '', email: '' }
    erb :'login', :locals => default.merge(params)
  end

  get '/post' do
    administrator_id = login_user_id

    output = Proc.new do |posts, publish_statuses, administrators|
      @title = '投稿一覧'
      erb :'post/index', :locals => {
        administrator_id: administrator_id,
        posts: posts,
        publish_statuses: publish_statuses,
        administrators: administrators,
      }
    end

    ListPostUseCase
      .new(
        nil,
        output,
        PostRepository.new(DB),
        PublishStatusRepository.new(DB),
        AdministratorRepository.new(DB),
      )
      .process
  end

  get '/post/add' do
    ps_repo = PublishStatusRepository.new(DB)
    publish_statuses = ps_repo.all

    @title = '投稿作成'
    erb :'post/add', :locals => {
      post: nil,
      publish_statuses: publish_statuses
    }
  end

  post '/post/add' do
    input = CreatePostUseCase::InputPort.new(
      title: params[:title] || '',
      content: params[:content] || '',
      publish_status_id: params[:publish_status],
      administrator_id: login_user_id,
    )

    output = Proc.new do |post|
      post_id = post.id
      redirect to('/post/add') if post_id.nil?
      redirect to('/post')
    end

    CreatePostUseCase
      .new(input, output, PostRepository.new(DB))
      .process
  end

  get '/post/edit/:id' do
    ps_repo = PublishStatusRepository.new(DB)
    publish_statuses = ps_repo.all

    input = ShowPostUseCase::InputPort.new(id: params[:id])

    output = Proc.new do |post, publish_status, administrator|
      @title = '投稿編集'
      erb :'post/add', :locals => {
        post: post,
        publish_statuses: publish_statuses
      }
    end

    ShowPostUseCase
      .new(
        input,
        output,
        PostRepository.new(DB),
        PublishStatusRepository.new(DB),
        AdministratorRepository.new(DB),
      )
      .process
  end

  post '/post/edit/:id' do
    input = UpdatePostUseCase::InputPort.new(
      id: params[:id],
      title: params[:title] || '',
      content: params[:content] || '',
      publish_status_id: params[:publish_status],
    )

    output = Proc.new do |post, updated_row_count|
      post_id = post.id
      redirect to(`/post/edit/#{post_id}`) if updated_row_count.zero?
      redirect to('/post')
    end

    UpdatePostUseCase
      .new(input, output, PostRepository.new(DB))
      .process
  end

  post '/post/delete/:id' do
    input = DeletePostUseCase::InputPort.new(id: params[:id])
    output = Proc.new do |post, deleted_row_count|
      redirect to('/post')
    end

    DeletePostUseCase
      .new(input, output, PostRepository.new(DB))
      .process
  end

  get '/api/v1/ping' do
    JSON.generate(status: :success, message: :pong)
  end

  get '/api/v1/posts' do
    output = Proc.new do |posts, publish_statuses, administrators|
      [
        200,
        { 'Content-Type' => 'application/json' },
        JSON.generate(posts.map { |post| post.to_h })
      ]
    end

    ListPostUseCase
      .new(
        nil,
        output,
        PostRepository.new(DB),
        PublishStatusRepository.new(DB),
        AdministratorRepository.new(DB),
      )
      .process
  end

  get '/api/v1/posts/:id' do
    input = ShowPostUseCase::InputPort.new(id: params[:id])

    output = Proc.new do |post, publish_status, administrator|
      [
        200,
        { 'Content-Type' => 'application/json' },
        JSON.generate(post.to_h)
      ]
    end

    ShowPostUseCase
      .new(
        input,
        output,
        PostRepository.new(DB),
        PublishStatusRepository.new(DB),
        AdministratorRepository.new(DB),
      )
      .process
  end

  error HTTPError::Forbidden do
    "<h1>403 Forbidden</h1>"
  end
end

