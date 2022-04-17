class PublishStatus
  attr_reader :id, :code, :label

  def initialize(id:, code:, label:)
    @id = id
    @code = code
    @label = label
  end

  def self.from_h(hash)
    self.new(id: hash[:id], code: hash[:code], label: hash[:label])
  end
end
