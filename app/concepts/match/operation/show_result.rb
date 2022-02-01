# frozen_string_literal: true

module Match::Operation
  class ShowResult < Trailblazer::Operation
    step :validate_criteria
    fail :invalid_criteria, fail_fast: true

    step :round_selection

    fail Common::Macro.SomethingWentWrong

    def validate_criteria(_ctx, **)
      Match.in(result: 'pending').size.zero? ||
        %w[SEMI_FINAL FINAL].include?(Setting.current_round)
    end

    def invalid_criteria(ctx, **)
      ctx[:error] = {
        msg: I18n.t('errors.invalid_criteria'),
        code: :unprocessable_entity
      }
    end

    def round_selection(ctx, **)
      ctx[:result] =
        case Setting.current_round
        when 'FIRST'
          Match::Operation::SecondRoundSel.call
        when 'SECOND'
          Match::Operation::QuarterRoundSel.call
        when 'QUARTER_FINAL'
          Match::Operation::SemiFinalRoundSel.call
        when 'SEMI_FINAL'
          Match::Operation::FinalRoundSel.call
        when 'FINAL'
          Match::Operation::WinnerSel.call
        end
    end
  end
end
