
class Sequel::Model
  plugin :validation_helpers
end

class Feed < Sequel::Model
  def before_create
    self.state ||= "new"
    self.date  ||= Date.today
  end

  def validate
    super
    validates_presence(:stream)
    validates_presence(:title)
    validates_unique(:title)
    validates_presence(:date)
  end

  def before_validation
  end
end
