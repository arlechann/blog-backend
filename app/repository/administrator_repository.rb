require_relative '../model/administrator'

class AdministratorRepository
  def initialize(db)
    @db = db
  end

  def all
    @db[<<~SQL].all.map { |admin| Administrator.from_h(admin) }
      SELECT id, email
      FROM administrators
    SQL
  end

  def find_by_id(administrator_id)
    Administrator.from_h(@db[<<~SQL, administrator_id].first!)
      SELECT id, email
      FROM administrators
      WHERE id = ?
    SQL
  rescue Sequel::NoMatchingRow => e
    raise Repository::NoDataError.new
  end
end