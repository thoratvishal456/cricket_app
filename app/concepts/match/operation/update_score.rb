# frozen_string_literal: true

module Match::Operation
  class UpdateScore < Trailblazer::Operation
    step :find_match
    step :update_score

    fail Common::Macro.SomethingWentWrong

    def find_match(ctx, params:, **)
      ctx[:match] = Match.find(id: params[:id])
    end

    def update_score(_ctx, match:, params:, **)
      match.t1_score = params[:match][:t1_score]
      match.t2_score = params[:match][:t2_score]
      match.result = if match.t1_score > match.t2_score
                       match.teams.first.name
                     else
                       match.teams.second.name
                     end
      match.update_score
    end
  end
end
