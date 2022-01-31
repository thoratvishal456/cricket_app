class Match
  include Mongoid::Document
  include Mongoid::Timestamps

  field :round, type: String
  field :group_name, type: String
  field :t1_score, type: Integer
  field :t2_score, type: Integer
  field :score, type: Hash
  field :result, type: String, default: "pending"


  has_and_belongs_to_many :teams

  def update_score
    names = teams.pluck(:name)
    self.score = {names[0] => t1_score, names[1] => t2_score}
    self.save
  end
end