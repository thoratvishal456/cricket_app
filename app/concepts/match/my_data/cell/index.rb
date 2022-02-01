# frozen_string_literal: true

require 'cell/partial'

module Match::MyData::Cell
  class Index < Trailblazer::Cell
    include ActionView::Helpers::FormOptionsHelper
    include SimpleForm::ActionViewExtensions::FormHelper
    include Partial

    def matches
      @model
    end

    def final?
      @match = Match.where(round: 'FINAL').first
      Setting.current_round.eql?('FINAL') && @match&.result != 'pending'
    end

    def winner
      return unless final?

      @match.winner
    end

    def runner_up
      return unless final?

      @match.looser
    end
  end
end
