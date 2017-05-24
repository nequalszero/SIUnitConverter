require_relative '../../../lib/si_unit_string'

class Units::SiController < ApplicationController
  def index
    si_unit_string = SIUnitString.new(params[:units])
    si_unit_string.parse
    render json: si_unit_string.formatted_result
  end
end
