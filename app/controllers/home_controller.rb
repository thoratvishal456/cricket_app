class HomeController < ApplicationController
  def index
    @group_a_matches = Match.where(group_name: "A")
    @group_b_matches = Match.where(group_name: "B")
  end
end