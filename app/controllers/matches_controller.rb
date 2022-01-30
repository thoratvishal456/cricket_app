class MatchesController < ApplicationController
  def index
    @matches = Match.all
  end

  def new
    @teams = Team.all
    @match = Match.new
  end

  def create
    params["match"]["team_ids"].reject!(&:blank?)
    @match = Match.new(permit_params)
    @match.team_ids = params["match"]["team_ids"]
    if @match.save
      flash[:notice] = 'New match added successfully'
      respond_to do |format|
        format.html { redirect_to matches_path }
      end
    else
      render :new
    end
  end

  def permit_params
    params.require(:match).permit(:group_name, :round)
  end
end
