require_relative './error/post'
require_relative '../../repository/error/repository'

class ShowPostForAdminUseCase
  InputPort = Struct.new(:id, keyword_init: true)

  def initialize(input_port, output_port, post_repo, publish_status_repo, administrator_repo)
    @input_port = input_port
    @output_port = output_port
    @post_repo = post_repo
    @publish_status_repo = publish_status_repo
    @administrator_repo = administrator_repo
  end

  def process
    begin
      post = @post_repo.find_by_id(@input_port.id)
      publish_status = @publish_status_repo.find_by_id(post.publish_status_id)
      administrator = @administrator_repo.find_by_id(post.administrator_id)
    rescue Repository::NoDataError => e
      raise UseCase::NoSuchPostError.new(e.message)
    end
    @output_port.call(post, publish_status, administrator)
  end
end
