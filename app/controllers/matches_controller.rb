class MatchesController < ApplicationController
  def index
    respond_to do |format|
      format.html do
        run Match::Operation::Index do |result|
          render cell(Match::MyData::Cell::Index, result[:matches])
        end
      end
    end
  end

  def new
    @teams = Team.all
    @match = Match.new
    @options = ''
    options_for_team('A')
    options_for_team('B')
  end

  def edit
    @match = Match.find(id: params[:id])
  end

  def create
    params['match']['team_ids'].reject!(&:blank?)
    result = Match::Operation::Create.call(
      params: permit_params,
      team_ids: params['match']['team_ids']
    )
    if result.success?
      flash[:notice] = 'New match added successfully'
      respond_to do |format|
        format.html { redirect_to matches_path }
      end
    else
      render :new
    end
  end
end
