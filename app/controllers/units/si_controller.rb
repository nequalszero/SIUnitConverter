require_relative '../../../lib/si_unit_string'

class Units::SiController < ApplicationController
  protect_from_forgery except: :index

  def index
    render json: {multiplication_factor: 1.0, unit_name: ""} if params[:units].nil?; return if performed?
    si_unit_string = SIUnitString.new(params[:units])
    si_unit_string.parse
    render json: si_unit_string.formatted_result
  end
end
