require_relative '../model/login_user'

class LoginUserRepository
  def initialize(db)
    @db = db
  end

  def all
    @db[<<~SQL].all.map { |admin| LoginUser.from_h(admin) }
      SELECT administrators.id AS id, email, password
      FROM administrators
      JOIN administrator_secrets
        ON administrators.id = administrator_secrets.administrator_id
    SQL
  end

  def find_by_id(administrator_id)
    LoginUser.from_h(@db[<<~SQL, administrator_id].first)
      SELECT administrators.id AS id, email, password
      FROM administrators
      JOIN administrator_secrets
        ON administrators.id = administrator_secrets.administrator_id
      WHERE administrators.id = ?
    SQL
  end

  def find_by_email(email)
    LoginUser.from_h(@db[<<~SQL, email].first)
      SELECT administrators.id AS id, email, password
      FROM administrators
      JOIN administrator_secrets
        ON administrators.id = administrator_secrets.administrator_id
      WHERE email = ?
    SQL
  end
end
