require 'logger'
require 'sequel'

require_relative '../model/administrator'
require_relative '../model/post'
require_relative '../model/publish_status'

DB ||= Sequel.connect('postgres://postgres:password@db:5432/blog', {
  logger: Logger.new('log/sql.log'),
})

class Database
  def all_administrators
    DB[<<~SQL].all.map { |admin| Administrator.from_h(admin) }
      SELECT id, email
      FROM administrators
    SQL
  end

  def find_administrator_by_email(email)
    DB[<<~SQL, email: email].first
      SELECT administrators.id AS id, email, password
      FROM administrators
      JOIN administrator_secrets
        ON administrators.id = administrator_secrets.administrator_id
      WHERE email = :email
    SQL
  end

  def all_posts
    DB[<<~SQL].all.map { |post| Post.from_h(post) }
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

  def find_post_by_id(post_id)
    Post.from_h(DB[<<~SQL, post_id].first)
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

  def all_publish_statuses
    DB[<<~SQL].all.map { |status| PublishStatus.from_h(status) }
      SELECT id, code, label
      FROM publish_statuses
    SQL
  end

  def find_publish_status_by_id(publish_status_id)
    PublishStatus.from_h(DB[<<~SQL, publish_status_id].first)
      SELECT id, code, label
      FROM publish_statuses
      WHERE id = ?
    SQL
  end

  def insert_post(post)
    post.set_id(
      DB[:posts].insert({
        title: post.title,
        content: post.content,
        publish_status_id: post.publish_status_id,
        administrator_id: post.administrator_id,
        created_at: post.created_at,
        last_updated_at: post.last_updated_at,
      })
    )
  end

  def update_post(post)
    DB[:posts].where({ id: post.id }).update({
      title: post.title,
      content: post.content,
      publish_status_id: post.publish_status_id,
      administrator_id: post.administrator_id,
      last_updated_at: post.last_updated_at,
    })
  end

  def delete_post_by_id(post_id)
    DB[:posts].where({ id: post_id }).delete
  end
end
