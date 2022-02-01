# frozen_string_literal: true

module Match::Operation
  class SecondRoundSel < Trailblazer::Operation
    step :matches

    fail Common::Macro.SomethingWentWrong

    def matches(_ctx, **)
      matches = Match.where(round: Setting.current_round)
      %w[A B].each { |g| second_round_pairs(g, matches) }
      Setting.current_round('SECOND')
    end

    private

      def second_round_pairs(group, matches)
        group_ids = matches.where(group_name: group).pluck(:team_ids).flatten
        group_ids.rotate(1).each_slice(2) do |a, b|
          new_match_a = Match.new(round: 'SECOND', group_name: group)
          new_match_a.teams = Team.in(id: [a, b])
          new_match_a.save
        end
      end
  end
end
