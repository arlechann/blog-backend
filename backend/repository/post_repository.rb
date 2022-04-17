require_relative '../model/post'

class PostRepository
  def initialize(db)
    @db = db
  end

  def all
    @db[<<~SQL].all.map { |post| Post.from_h(post) }
      SELECT
        posts.id AS id,
        title,
        content,
        publish_status_id,
        administrator_id,
        created_at,
        last_updated_at
      FROM posts
      INNER JOIN publish_statuses
        ON posts.publish_status_id = publish_statuses.id
      INNER JOIN administrators
        ON posts.administrator_id = administrators.id
    SQL
  end

  def find_by_id(post_id)
    Post.from_h(@db[<<~SQL, post_id].first)
      SELECT
        posts.id AS id,
        title,
        content,
        publish_status_id,
        administrator_id,
        created_at,
        last_updated_at
      FROM posts
      INNER JOIN publish_statuses
        ON posts.publish_status_id = publish_statuses.id
      INNER JOIN administrators
        ON posts.administrator_id = administrators.id
      WHERE posts.id = ?
    SQL
  end

  def insert(post)
    post.set_id(
      @db[:posts].insert({
        title: post.title,
        content: post.content,
        publish_status_id: post.publish_status_id,
        administrator_id: post.administrator_id,
        created_at: post.created_at,
        last_updated_at: post.last_updated_at,
      })
    )
  end

  def update(post)
    @db[:posts].where({ id: post.id }).update({
      title: post.title,
      content: post.content,
      publish_status_id: post.publish_status_id,
      administrator_id: post.administrator_id,
      last_updated_at: post.last_updated_at,
    })
  end

  def delete_by_id(post_id)
    @db[:posts].where({ id: post_id }).delete
  end
end