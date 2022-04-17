class CreatePostUseCase
  InputPort = Struct.new(
    :title,
    :content,
    :publish_status_id,
    :administrator_id,
    keyword_init: true,
  )

  def initialize(input_port, output_port, post_repo)
    @input_port = input_port
    @output_port = output_port
    @post_repo = post_repo
  end

  def process
    post = Post.new(
      title: @input_port.title,
      content: @input_port.content,
      publish_status_id: @input_port.publish_status_id,
      administrator_id: @input_port.administrator_id,
    )
    @post_repo.insert(post)
    @output_port.call(post)
  end
end
