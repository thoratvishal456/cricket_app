# frozen_string_literal: true

module Match::Operation
  class Create < Trailblazer::Operation
    step :build_match

    fail Common::Macro.SomethingWentWrong

    def build_match(_ctx, params:, team_ids:, **)
      match = Match.new(params)
      match.team_ids = team_ids
      match.save
    end
  end
end
