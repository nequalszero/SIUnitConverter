require_relative './conversions.rb'
require_relative './modules/no_parenthesis_module.rb'

class SIUnitString
  include NoParenthesisModule
  attr_reader :string, :factor

  def initialize(string)
    @string = string.gsub(/\s+/, '')
  end

  def parse
    if needs_complex_structure?
      @result_object = parse_complex_string
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

    result = {factor: 1.0, units_array: [], operator_start_idx: 0}
    string_start_idx = 0

    until result[:operator_start_idx] >= @operator_objects.length do
      current_operator = @operator_objects[result[:operator_start_idx]]

      if current_operator[:type] == :parenthese
        # Handle empty parenthesis
        if current_operator[:close_idx] == current_operator[:open_idx] + 1
          result[:units_array].concat(["(", ")"])
          result[:operator_start_idx] += 1
        else
          result[:units_array] << "("
          # if (result[:operator_start_idx] += 1) < @operator_objects.length
          subresult = parse_parenthesis_group(result[:operator_start_idx] += 1)
          add_subresult(result, subresult)
          # end
          result[:units_array] << ")"
        end

        string_start_idx = current_operator[:close_idx] + 1
      else
        si_unit = @string[string_start_idx..current_operator[:idx]-1]
        si_unit_counterpart = SI_UNIT_COUNTERPARTS[si_unit]
        add_si_unit_counterpart(result, si_unit_counterpart, current_operator)

        string_start_idx = current_operator[:idx] + 1
        result[:operator_start_idx] += 1
      end

      result[:last_operator] = current_operator[:operator]
    end

    result
  end

  def parse_parenthesis_group(operator_start_idx)
    parenthesis_object = @operator_objects[operator_start_idx]
    return {
      factor: 1.0,
      units_array: ['()'],
      operator_start_idx: operator_start_idx + 1
    } if parenthesis_object[:close_idx] == parenthesis_object[:open_idx] + 1

    stop_idx = parenthesis_object[:close_idx]
    result = {factor: 1.0, units_array: ['('], operator_start_idx: operator_start_idx + 1}

    string_start_idx = parenthesis_object[:open_idx] + 1
    current_operator = @operator_objects[result[:operator_start_idx]]

    while operator_in_range(current_operator, stop_idx) do
      # if current operator is a * or / operator
      if current_operator[:type] == :operator
        si_unit = @string[string_start_idx..current_operator[:idx]-1]
        si_unit_counterpart = SI_UNIT_COUNTERPARTS[si_unit]

        add_si_unit_counterpart(result, si_unit_counterpart, current_operator)
        result[:last_operator] = current_operator[:operator]
        string_start_idx = operator_obj[:idx] + 1
        result[:operator_start_idx] += 1
      # if current operator is a parenthesis
      elsif current_operator[:type] == :parenthese
        subresult = parse_parenthesis_group(result[:operator_start_idx])

        # handles updating result[:operator_start_idx] and result[:units_array]
        add_subresult(result, subresult)
        string_start_idx = current_operator[:close_idx] + 1
      end

      current_operator = @operator_objects[result[:operator_start_idx]]
    end

    result[:units_array] << ')'
    result
  end

  def operator_in_range(operator, stop_idx)
    return false if operator.nil?

    (operator[:idx] && operator[:idx] < stop_idx) ||
      (operator[:open_idx] && operator[:open_idx] < stop_idx)
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
  def add_subresult(result, subresult)
    if result[:last_operator].nil? || result[:last_operator] == "*"
      result[:factor] *= subresult[:factor]
    else
      result[:factor] /= subresult[:factor]
    end

    result[:units_array].concat(subresult[:units_array])
    result[:operator_start_idx] = subresult[:operator_start_idx]
  end

  private
  def needs_complex_structure?
    @string.match('\(') ? true : false
  end

  def find_operators_and_parenthesis
    parenthesis_arr= []

    @string.each_char.with_index do |char, idx|
      @operator_objects << {idx: idx, operator: char, type: :operator} if char == "*" || char == "/"
      if char == "("
        parenthesis_obj = {type: :parenthese, open_idx: idx}
        @operator_objects << parenthesis_obj
        parenthesis_arr<< parenthesis_obj
      elsif char == ")"
        parenthesis_obj = parenthesis_arr.pop
        parenthesis_obj[:close_idx] = idx
      end
    end
  end



end
