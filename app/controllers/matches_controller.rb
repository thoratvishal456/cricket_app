class MatchesController < ApplicationController
  def index
    @matches = Match.where(round: $CURRENT_ROUND)
  end

  def new
    @teams = Team.all
    @match = Match.new
    @options = ""
    options_for_team("A")
    options_for_team("B")
  end

  def options_for_team(group)
    Team.where(group_name: group).all.each do |team|
      @options += "<option value="+team.id+">"+team.name+" - Group "+team.group_name+"</option>"
    end
  end

  def edit
    @match = Match.find(id: params[:id])
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

  def update_score
    @match = Match.find(id: params[:id])
    @match.t1_score = params[:match][:t1_score]
    @match.t2_score = params[:match][:t2_score]
    
    @match.result = @match.t1_score > @match.t2_score ? 
      @match.teams.first.name : @match.teams.second.name

    if @match.save
      @match.update_score
      flash[:notice] = 'Score is updated successfully'
      respond_to do |format|
        format.html { redirect_to matches_path }
      end
    else
      flash[:alert] = 'Something went wrong'
      render :edit
    end
  end

  def show_result
    if Match.in(result: "pending").size == 0 || ["SEMI_FINAL", "FINAL"].include?($CURRENT_ROUND)
      @matches = Match.where(round: $CURRENT_ROUND)
      if $CURRENT_ROUND == "FIRST"
        group_a_ids = @matches.where(group_name: "A").pluck(:team_ids).flatten
        group_a_ids.rotate(1).each_slice(2) do |a, b|
          new_match_a = Match.new(round: "SECOND", group_name: "A")
          new_match_a.teams = Team.in(id: [a, b])
          new_match_a.save
        end
        group_b_ids = @matches.where(group_name: "B").pluck(:team_ids).flatten
        group_b_ids.rotate(1).each_slice(2) do |c, d|
          new_match_b = Match.new(round: "SECOND", group_name: "B")
          new_match_b.teams = Team.in(id: [c, d])
          new_match_b.save
        end
        $CURRENT_ROUND = "SECOND"
      elsif $CURRENT_ROUND == "SECOND"
        all_qualified_names = second_qualified("A") + second_qualified("B")
        @qualified_teams = quarter_final_selection(all_qualified_names)
        @qualified_teams.each_slice(2) do |a, b|
          new_match_qfinal = Match.new(round: "QUARTER_FINAL", group_name: "BOTH")
          new_match_qfinal.teams = Team.in(name: [a, b])
          new_match_qfinal.save
        end
        $CURRENT_ROUND = "QUARTER_FINAL"
      elsif $CURRENT_ROUND == "QUARTER_FINAL"
        semi_final_selection
      elsif $CURRENT_ROUND == "SEMI_FINAL"
        final_match_selection
      elsif $CURRENT_ROUND == "FINAL"
        find_winner
      end
    end
  end


  def second_qualified(group)
    match_data = Match.where(group_name: group).pluck(:result).group_by(&:itself).map { |k,v| [k, v.count] }.to_h
    already = match_data.select {|k, v| v > 1}
    second_round_teams = already.keys
    remaining = match_data.select {|k, v| v == 1}
    @match1 = Match.where(result: remaining.keys.first).first
    @match2 = Match.where(result: remaining.keys.second).first
    remaining_qualified = @match1 && @match2 && ( @match1.score[@match1.result] > @match2.score[@match2.result] ? @match1.result : @match2.result )
    second_round_teams << remaining_qualified if remaining_qualified
    second_round_teams
  end

  def quarter_final_selection(names)
    sorted_matches = Match.in(result: names).pluck(:result).group_by(&:itself).map { |k,v| [k, v.count] }.to_h
    data = sorted_matches.select {|k, v| v > 1}.keys

    all = {}

    data.each do |team|
      match = Match.where(result: team)
      total_score = match.map {|m| m.score[m.result]}.reduce(:+)
      all[team] = total_score
    end

    sorted_teams_by_score = all.sort_by {|k, v| -v}.to_h.keys
    sorted_teams_by_score += ( names - sorted_teams_by_score )
  end

  def semi_final_selection
    m1 = Match.where(round: "QUARTER_FINAL").first
    final_match = Match.new(round: "FINAL", group_name: "BOTH")
    final_match.teams << Team.find_by(name: m1.result)
    final_match.save
    
    m2 = Match.where(round: "QUARTER_FINAL").second
    temp = m1.score
    temp.delete(m1.result)

    semi_final = Match.new(round: "SEMI_FINAL", group_name: "BOTH")
    semi_final.teams << Team.find_by(name: temp.keys.first)
    semi_final.teams << Team.find_by(name: m2.result)
    semi_final.save
    $CURRENT_ROUND = "SEMI_FINAL"
    @qualified_teams = [temp.keys.first, m2.result]
  end

  def final_match_selection
    team_name = Match.find_by(round: "SEMI_FINAL").result
    team = Team.find_by(name: team_name)
    final_match = Match.find_by(round: "FINAL")
    final_match.teams << team
    final_match.save
    $CURRENT_ROUND = "FINAL"
    @qualified_teams = final_match.teams.pluck(:name)
  end

  def find_winner
    match = Match.find_by(round: "FINAL")
    @winner = Team.find_by(name: match.result)
    temp = match.score
    temp.delete(match.result)
    @runner_up = Team.find_by(name: temp.keys.first)
  end

  def permit_params
    params.require(:match).permit(:group_name, :round)
  end
end
