class Team
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :group_name, type: String
  field :qualification_category, type: String
  field :status, type: String

  has_many :players
  has_and_belongs_to_many :matches
end