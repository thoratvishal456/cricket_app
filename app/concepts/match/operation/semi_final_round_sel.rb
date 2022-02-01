# frozen_string_literal: true

module Match::Operation
  class SemiFinalRoundSel < Trailblazer::Operation
    step :find_match1
    step :final_match_selection
    step :find_match2
    step :matches

    fail Common::Macro.SomethingWentWrong

    def find_match1(ctx, **)
      ctx[:match1] = Match.where(round: 'QUARTER_FINAL').first
    end

    def final_match_selection(_ctx, match1:, **)
      final_match = Match.new(round: 'FINAL', group_name: 'BOTH')
      final_match.teams << Team.find_by(name: match1.result)
      final_match.save
    end

    def find_match2(ctx, **)
      ctx[:match2] = Match.where(round: 'QUARTER_FINAL').second
    end

    def matches(ctx, match1:, match2:, **)
      temp = match1.score
      temp.delete(match1.result)
      semi_final = Match.new(round: 'SEMI_FINAL', group_name: 'BOTH')
      semi_final.teams << Team.find_by(name: temp.keys.first)
      semi_final.teams << Team.find_by(name: match2.result)
      semi_final.save
      Setting.current_round('SEMI_FINAL')
      ctx[:qualified_teams] = [temp.keys.first, match2.result]
    end
  end
end
