class Player
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :age, type: String

  belongs_to :team
  belongs_to :role
end