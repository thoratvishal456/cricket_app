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
      flash[:notice] = I18n.t('flash.new_match')
      respond_to do |format|
        format.html { redirect_to matches_path }
      end
    else
      render :new
    end
  end

  def update_score
    result = Match::Operation::UpdateScore.call(
      params: params
    )
    if result.success?
      flash[:notice] = I18n.t('flash.score_added')
      respond_to do |format|
        format.html { redirect_to matches_path }
      end
    else
      flash[:alert] = I18n.t('errors.something_went_wrong')
      render :edit
    end
  end

  def show_result
    respond_to do |format|
      format.html do
        Match::Operation::ShowResult.call(
          params: params
        )
        flash[:notice] = I18n.t('flash.result_success')
        redirect_to matches_path
      end
    end
  end

  def permit_params
    params.require(:match).permit(:group_name, :round)
  end

  private

    def options_for_team(group)
      Team.where(group_name: group).all.each do |team|
        @options += team.formated_team_name
      end
    end
end
