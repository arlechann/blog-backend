class UpdatePostUseCase
  InputPort = Struct.new(
    :id,
    :title,
    :content,
    :publish_status_id,
    keyword_init: true,
  )

  def initialize(input_port, output_port, post_repo)
    @input_port = input_port
    @output_port = output_port
    @post_repo = post_repo
  end

  def process
    post = @post_repo.find_by_id(@input_port.id)
    post.update_title(@input_port.title)
    post.update_content(@input_port.content)
    post.update_publish_status_id(@input_port.publish_status_id)
    updated_row_count = @post_repo.update(post)
    @output_port.call(post, updated_row_count)
  end
end
