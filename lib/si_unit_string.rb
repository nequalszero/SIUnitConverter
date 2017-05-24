require_relative './conversions.rb'
require_relative './modules/no_parenthesis_module.rb'
require_relative './modules/parenthesis_module.rb'

# Class that takes a string of units, and parses them into standard SI units,
#   creating a formatted_result instance variable with properties :unit_name
#   and :multiplication_factor.
class SIUnitString
  include NoParenthesisModule
  include ParenthesisModule

  attr_reader :string, :num_decimals, :formatted_result

  # Inputs:
  # => string: string of units, multiplication/division operators, and parenthesis,
  # => num_decimals: optional integer for number of decimal places to round the
  #                  multiplication_factor to, defaults to 14.
  def initialize(string, num_decimals = 14)
    @string = string.gsub(/\s+/, '')
    @num_decimals = num_decimals
  end

  # Method that parses the units string, populates and returns the @formatted_result
  #   instance variable, which has 2 keys:
  # => unit_name: string of converted units,
  # => multiplication_factor: float representing factor to convert @string into
  #                           @formatted_result[:unit_name]
  def parse
    if needs_complex_structure?
      parse_complex_string
    else
      parse_simple_string
    end

    @formatted_result = {
      unit_name: @result_object[:units_array].join(""),
      multiplication_factor: @result_object[:factor].round(@num_decimals)
    }
  end

  private

  # Returns true if any parenthesis are found in the input string.
  def needs_complex_structure?
    @string.match('\(') ? true : false
  end
end
