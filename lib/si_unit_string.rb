require_relative './conversions.rb'
require_relative './modules/no_parenthesis_module.rb'
require_relative './modules/parenthesis_module.rb'

class SIUnitString
  include NoParenthesisModule
  include ParenthesisModule
  attr_reader :string, :factor

  def initialize(string)
    @string = string.gsub(/\s+/, '')
  end

  def parse
    if needs_complex_structure?
      parse_complex_string
    else
      @result_object = parse_simple_string
    end

    {
      unit_name: @result_object[:units_array].join(""),
      multiplication_factor: @result_object[:factor].round(14)
    }
  end


  def parse_complex_string
    @operator_objects = []
    find_operators_and_parenthesis

    @result_object = {factor: 1.0, units_array: [], operator_start_idx: 0}
    string_idx = 0

    @operator_objects.each_with_index do |operator_obj, operator_idx|
      if operator_obj.class == ParenthesisGroup
        operator_obj.process_children(@string)

        add_subresult(operator_obj.result)
        string_idx = operator_obj.close_idx + 1
      else
        si_unit = @string[string_idx..operator_obj[:idx]-1]
        si_unit_counterpart = SI_UNIT_COUNTERPARTS[si_unit]
        add_si_unit_counterpart(@result_object, si_unit_counterpart, operator_obj)

        string_idx = operator_obj[:idx] + 1
      end
    end

    add_final_unit(string_idx)
  end

  def add_final_unit(string_idx)
    si_unit = @string[string_idx..@string.length-1]
    si_unit_counterpart = SI_UNIT_COUNTERPARTS[si_unit]

    add_si_unit_counterpart(@result_object, si_unit_counterpart)
  end

  # Inputs:
  #   result: {units_array: <array of strings>, factor: <integer or float>},
  #   si_unit_counterpart: {unit: <string>, factor: <integer or float>}, and
  #   operator_obj: (optional) hash of form {idx: <integer>, operator: "*" or "/"}
  # Returns nil
  def add_si_unit_counterpart(result, si_unit_counterpart, operator_obj = nil)
    # handles the first unit of a string
    if result[:units_array].empty?
      result[:factor] *= si_unit_counterpart[:factor]
    # handles subsequent units preceded by operators
    elsif ["*", "/"].include?(result[:units_array].last)
      result[:factor] *= si_unit_counterpart[:factor] if result[:units_array].last == "*"
      result[:factor] /= si_unit_counterpart[:factor] if result[:units_array].last == "/"
    end

    result[:units_array] << si_unit_counterpart[:unit] unless si_unit_counterpart.nil?
    result[:units_array] << operator_obj[:operator] unless operator_obj.nil?
  end

  # Adds a subresult (parenthese group) to the main result.
  def add_subresult(subresult)
    if @result_object[:units_array].last.nil? || ["*", "(", ")"].include?(@result_object[:units_array].last)
      @result_object[:factor] *= subresult[:factor]
    else
      @result_object[:factor] /= subresult[:factor]
    end

    @result_object[:units_array].concat(subresult[:units_array])
    @result_object[:operator_start_idx] = subresult[:operator_start_idx]
  end

  private
  def needs_complex_structure?
    @string.match('\(') ? true : false
  end

end
