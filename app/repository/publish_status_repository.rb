require_relative '../model/publish_status'

class PublishStatusRepository
  def initialize(db)
    @db = db
  end

  def all
    @db[<<~SQL].all.map { |status| PublishStatus.from_h(status) }
      SELECT id, code, label
      FROM publish_statuses
    SQL
  end

  def find_by_id(publish_status_id)
    PublishStatus.from_h(@db[<<~SQL, publish_status_id].first)
      SELECT id, code, label
      FROM publish_statuses
      WHERE id = ?
    SQL
  end
end