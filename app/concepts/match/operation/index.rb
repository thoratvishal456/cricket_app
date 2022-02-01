# frozen_string_literal: true

module Match::Operation
  class Index < Trailblazer::Operation
    step :matches

    fail Common::Macro.SomethingWentWrong

    def matches(ctx, **)
      ctx[:matches] = Match.where(round: Setting.current_round)
    end
  end
end
