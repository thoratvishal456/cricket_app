class MatchesController < ApplicationController
  def index
    respond_to do |format|
      format.html do
        run Match::Operation::Index do |result|
          render cell(Match::MyData::Cell::Index, result[:matches])
        end
      end
    end
  end
end
