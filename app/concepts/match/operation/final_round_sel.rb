# frozen_string_literal: true

module Match::Operation
  class FinalRoundSel < Trailblazer::Operation
    step :matches

    fail Common::Macro.SomethingWentWrong

    def matches(ctx, **)
      team_name = Match.find_by(round: 'SEMI_FINAL').result
      team = Team.find_by(name: team_name)
      final_match = Match.find_by(round: 'FINAL')
      final_match.teams << team
      final_match.save
      Setting.current_round('FINAL')
      ctx[:qualified_teams] = final_match.teams.pluck(:name)
    end
  end
end
