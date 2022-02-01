# Team model to store team deatils
class Team
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :group_name, type: String

  has_many :players
  has_and_belongs_to_many :matches

  validates_presence_of :name

  def formated_team_name
    '<option value='
      .concat(id)
      .concat('>')
      .concat(name)
      .concat(' - Group ')
      .concat(group_name)
      .concat('</option>')
  end
end
