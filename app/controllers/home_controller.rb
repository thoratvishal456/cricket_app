class HomeController < ApplicationController
  def index
    @group_a_matches = Match.where(group_name: "A", round: $CURRENT_ROUND)
    @group_b_matches = Match.where(group_name: "B", round: $CURRENT_ROUND)
  end
end