require_relative 'administrator'

class LoginUser < Administrator
  attr_reader :password

  def initialize(id: nil, email:, password:)
    super(id: id, email: email)
    @password = password
  end

  def self.from_h(hash)
    self.new(id: hash[:id], email: hash[:email], password: hash[:password])
  end

  def to_h
    { id: id, email: email, password: password }
  end
end
