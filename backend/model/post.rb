require 'time'

class Post
  attr_reader :id, :title, :content, :publish_status_id, :administrator_id, :created_at, :last_updated_at

  def initialize(
    id: nil,
    title: '',
    content: '',
    publish_status_id:,
    administrator_id:,
    created_at: Time.now.iso8601,
    last_updated_at: Time.now.iso8601
  )
    @id = id
    @title = title
    @content = content
    @publish_status_id = publish_status_id
    @administrator_id = administrator_id
    @created_at = created_at
    @last_updated_at = last_updated_at
  end

  def set_id(id)
    throw Error.new('Cannot change post.id') unless @id.nil?
    @id = id
  end

  def self.from_h(hash)
    self.new(
      id: hash[:id],
      title: hash[:title],
      content: hash[:content],
      publish_status_id: hash[:publish_status_id],
      administrator_id: hash[:administrator_id],
      created_at: hash[:created_at],
      last_updated_at: hash[:last_updated_at],
    )
  end

  def to_h
    {
      id: id,
      title: title,
      content: content,
      publish_status_id: publish_status_id,
      administrator_id: administrator_id,
      created_at: created_at,
      last_updated_at: last_updated_at,
    }
  end

  def update_title(title, last_updated_at = Time.now.iso8601)
    return false if @title == title
    @title = title
    @last_updated_at = last_updated_at
    true
  end

  def update_content(content, last_updated_at = Time.now.iso8601)
    return false if @content == content
    @content = content
    @last_updated_at = last_updated_at
    true
  end

  def update_publish_status_id(publish_status_id, last_updated_at = Time.now.iso8601)
    return false if @publish_status_id == publish_status_id
    @publish_status_id = publish_status_id
    @last_updated_at = last_updated_at
    true
  end
end
