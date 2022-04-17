class Administrator
  attr_reader :id, :email

  def initialize(id: nil, email:)
    @id = id
    @email = email
  end

  def self.from_h(hash)
    self.new(id: hash[:id], email: hash[:email])
  end
end
