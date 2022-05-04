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
end
