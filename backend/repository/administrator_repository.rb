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
end