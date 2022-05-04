class ListPostsForVisitorUseCase
  def initialize(
    input_port,
    output_port,
    post_repo,
    publish_status_repo
  )
    @input_port = input_port
    @output_port = output_port
    @post_repo = post_repo
    @publish_status_repo = publish_status_repo
  end

  def process
    publish_status = @publish_status_repo.find_by_code('published')
    posts = @post_repo
      .find_all_by_publish_status_id(publish_status.id)
      .map do |post|
        {
          slug: post.slug,
          title: post.title,
          content: post.content,
          created_at: post.created_at,
          last_updated_at: post.last_updated_at,
        }
      end
    @output_port.call(posts)
  end
end
