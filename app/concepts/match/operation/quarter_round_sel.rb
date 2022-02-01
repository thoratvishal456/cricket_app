# frozen_string_literal: true

module Match::Operation
  class QuarterRoundSel < Trailblazer::Operation
    step :all_qualified_names
    step :sorted_teams
    step :qualified_teams_score
    step :qualified_teams
    step :matches

    fail Common::Macro.SomethingWentWrong

    def all_qualified_names(ctx, **)
      ctx[:all_qualified_names] = second_qualified('A') + second_qualified('B')
    end

    def sorted_teams(ctx, all_qualified_names:, **)
      sorted_matches =
        Match.in(result: all_qualified_names)
             .pluck(:result).group_by(&:itself)
             .map do |k, v|
          [k, v.count]
        end.to_h
      ctx[:sorted_teams] = sorted_matches.select { |_k, v| v > 1 }.keys
    end

    def qualified_teams_score(ctx, sorted_teams:, **)
      ctx[:team_with_score] = {}
      sorted_teams.each do |team|
        match = Match.where(result: team)
        total_score = match.map { |m| m.score[m.result] }.reduce(:+)
        ctx[:team_with_score][team] = total_score
      end
    end

    def qualified_teams(ctx, all_qualified_names:, team_with_score:, **)
      qualified_teams = team_with_score.sort_by { |_k, v| -v }.to_h.keys
      qualified_teams += (all_qualified_names - qualified_teams)

      ctx[:qualified_teams] = qualified_teams
    end

    def matches(_ctx, qualified_teams:, **)
      qualified_teams.each_slice(2) do |a, b|
        match = Match.new(round: 'QUARTER_FINAL', group_name: 'BOTH')
        match.teams = Team.in(name: [a, b])
        match.save
      end
      Setting.current_round('QUARTER_FINAL')
    end

    private

      def second_qualified(group)
        match_data =
          Match.where(group_name: group)
               .pluck(:result)
               .group_by(&:itself)
               .map do |k, v|
            [k, v.count]
          end.to_h
        sorted_teams = match_data.select { |_k, v| v > 1 }.keys
        remaining_teams = match_data.select { |_k, v| v == 1 }
        match1 = Match.where(result: remaining_teams.keys.first).first
        match2 = Match.where(result: remaining_teams.keys.second).first

        if match1 && match2
          sorted_teams << remaining_qualify_checker(match1, match2)
        end
        sorted_teams
      end

      def remaining_qualify_checker(match1, match2)
        if match1.score[match1.result] > match2.score[match2.result]
          match1.result
        else
          match2.result
        end
      end
  end
end
