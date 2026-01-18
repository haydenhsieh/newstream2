
class Sequel::Model
  plugin :validation_helpers
end

class Feed < Sequel::Model
  def validate
    super
    validates_presence(:stream)
    validates_presence(:title)
    validates_presence(:date)
  end

  def before_validation
  end
end
