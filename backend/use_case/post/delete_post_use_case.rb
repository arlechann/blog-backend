class DeletePostUseCase
  InputPort = Struct.new(
    :id,
    keyword_init: true,
  )

  def initialize(input_port, output_port, post_repo)
    @input_port = input_port
    @output_port = output_port
    @post_repo = post_repo
  end

  def process
    post = @post_repo.find_by_id(@input_port.id)
    deleted_row_count = @post_repo.delete_by_id(@input_port.id)
    @output_port.call(post, deleted_row_count)
  end
end
