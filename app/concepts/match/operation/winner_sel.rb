# frozen_string_literal: true

module Match::Operation
  class WinnerSel < Trailblazer::Operation
    step :matches

    fail Common::Macro.SomethingWentWrong

    def matches(ctx, **)
      match = Match.find_by(round: 'FINAL')
      ctx[:winner] = Team.find_by(name: match.result)
      temp = match.score
      temp.delete(match.result)
      ctx[:runner_up] = Team.find_by(name: temp.keys.first)
    end
  end
end
