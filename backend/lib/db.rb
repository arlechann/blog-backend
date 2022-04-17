require 'logger'
require 'sequel'

DB ||= Sequel.connect('postgres://postgres:password@db:5432/blog', {
  logger: Logger.new('log/sql.log'),
})

class Database
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
    DB[<<~SQL].all
      SELECT
        posts.id AS id,
        title,
        content,
        publish_status_id,
        publish_statuses.code AS publish_status_code,
        publish_statuses.label AS publish_status_label,
        administrator_id,
        administrators.email AS administrator_email,
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
    DB[<<~SQL, post_id].first
      SELECT
        posts.id AS id,
        title,
        content,
        publish_status_id,
        publish_statuses.code AS publish_status_code,
        publish_statuses.label AS publish_status_label,
        administrator_id,
        administrators.email AS administrator_email,
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
    DB[<<~SQL].all
      SELECT id, code, label
      FROM publish_statuses
    SQL
  end

  def insert_post(post)
    DB[:posts].insert(post)
  end

  def update_post(post)
    DB[:posts].where({ id: post[:id] }).update({
      title: post[:title],
      content: post[:content],
      publish_status_id: post[:publish_status_id],
      administrator_id: post[:administrator_id],
      last_updated_at: post[:last_updated_at],
    })
  end

  def delete_post_by_id(post_id)
    DB[:posts].where({ id: post_id }).delete
  end
end
