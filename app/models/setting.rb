class Setting
  include Mongoid::Document

  field :key, type: String
  field :value, type: String

  validates_uniqueness_of :key

  # Classical set method
  def self.current_round(round = '')
    if round.present?
      find_or_create_by(key: 'CURRENT_ROUND').update(value: round)
    else
      find_or_create_by(key: 'CURRENT_ROUND').value
    end
  end
end
