class ListPostUseCase
  def initialize(
    input_port,
    output_port,
    post_repo,
    publish_status_repo,
    admin_repo
  )
    @input_port = input_port
    @output_port = output_port
    @post_repo = post_repo
    @publish_status_repo = publish_status_repo
    @admin_repo = admin_repo
  end

  def process
    posts = @post_repo.all
    publish_statuses = @publish_status_repo.all
    administrators = @admin_repo.all
    @output_port.call(posts, publish_statuses, administrators)
  end
end
