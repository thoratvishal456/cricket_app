class Match
  include Mongoid::Document
  include Mongoid::Timestamps

  field :round, type: String
  field :group_name, type: String
  field :score, type: Integer
  field :status, type: String


  has_and_belongs_to_many :teams
end