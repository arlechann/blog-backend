require_relative '../model/publish_status'
require_relative './error/repository'

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
    PublishStatus.from_h(@db[<<~SQL, publish_status_id].first!)
      SELECT id, code, label
      FROM publish_statuses
      WHERE id = ?
    SQL
  rescue Sequel::NoMatchingRow => e
    raise Repository::NoDataError.new
  end

  def find_by_code(code)
    PublishStatus.from_h(@db[<<~SQL, code].first!)
      SELECT id, code, label
      FROM publish_statuses
      WHERE code = ?
    SQL
  rescue Sequel::NoMatchingRow => e
    raise Repository::NoDataError.new
  end
end