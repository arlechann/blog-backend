require_relative '../model/post'

class PostRepository
  def initialize(db)
    @db = db
  end

  def all
    @db[<<~SQL].all.map { |post| Post.from_h(post) }
      SELECT
        posts.id AS id,
        slugs.slug AS slug,
        title,
        content,
        publish_status_id,
        administrator_id,
        created_at,
        last_updated_at
      FROM posts
      LEFT JOIN slugs
        ON posts.id = slugs.post_id
    SQL
  end

  def find_by_id(post_id)
    Post.from_h(@db[<<~SQL, post_id].first)
      SELECT
        posts.id AS id,
        slugs.slug AS slug,
        title,
        content,
        publish_status_id,
        administrator_id,
        created_at,
        last_updated_at
      FROM posts
      LEFT JOIN slugs
        ON posts.id = slugs.post_id
      WHERE posts.id = ?
    SQL
  end

  def find_by_slug(slug)
    Post.from_h(@db[<<~SQL, slug].first)
      SELECT
        posts.id AS id,
        slugs.slug AS slug,
        title,
        content,
        publish_status_id,
        administrator_id,
        created_at,
        last_updated_at
      FROM posts
      INNER JOIN slugs
        ON posts.id = slugs.post_id
      WHERE slugs.slug = ?
    SQL
  end

  def find_all_by_publish_status_id(publish_status_id)
    @db[<<~SQL, publish_status_id].all.map { |post| Post.from_h(post) }
      SELECT
        posts.id AS id,
        slugs.slug AS slug,
        title,
        content,
        publish_status_id,
        administrator_id,
        created_at,
        last_updated_at
      FROM posts
      LEFT JOIN slugs
        ON posts.id = slugs.post_id
      WHERE posts.publish_status_id = ?
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
    save_slug(post.id, post.slug)
    nil
  end

  def update(post)
    updated_row = @db[:posts].where({ id: post.id }).update({
      title: post.title,
      content: post.content,
      publish_status_id: post.publish_status_id,
      administrator_id: post.administrator_id,
      last_updated_at: post.last_updated_at,
    })
    slug_updated_row = save_slug(post.id, post.slug)
    [updated_row, slug_updated_row].max
  end

  def delete_by_id(post_id)
    @db[:posts].where({ id: post_id }).delete
    nil
  end

  private

  def save_slug(post_id, slug)
    if slug.nil?
      delete_slug_by_post_id(post_id)
    else
      slug_updated_row = update_slug(post_id, slug)
      if slug_updated_row == 0
        insert_slug(post_id, slug)
        1
      else
        slug_updated_row
      end
    end
  end

  def insert_slug(post_id, slug)
    @db[:slugs].insert({
      post_id: post_id,
      slug: slug,
    })
  end

  def update_slug(post_id, slug)
    @db[:slugs]
      .where({ post_id: post_id })
      .update({
        slug: slug
      })
  end

  def delete_slug_by_post_id(post_id)
    @db[:slugs].where({ post_id: post_id }).delete
  end
end