class ShowPostForVisitorUseCase
  InputPort = Struct.new(:slug, keyword_init: true)

  def initialize(input_port, output_port, post_repo, publish_status_repo)
    @input_port = input_port
    @output_port = output_port
    @post_repo = post_repo
    @publish_status_repo = publish_status_repo
  end

  def process
    post = @post_repo.find_by_slug(@input_port.slug)
    publish_status = @publish_status_repo.find_by_code('published')
    if post.publish_status_id == publish_status.id
      @output_port.call({
        slug: post.slug,
        title: post.title,
        content: post.content,
        created_at: post.created_at,
        last_updated_at: post.last_updated_at,
      })
    else
      @output_port.call(nil)
    end
  end
end
