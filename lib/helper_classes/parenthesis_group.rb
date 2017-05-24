require_relative '../conversions.rb'

class ParenthesisGroup
  attr_reader :open_idx, :close_idx, :result

  def initialize(start_idx)
    @start_idx = start_idx
    @children = []
    @result = {
      factor: 1.0,
      units_array: ['(']
    }
  end

  def add_child(child)
    @children << child
  end

  def set_close_idx(idx)
    @close_idx ||= idx
  end

  def process_children(string)
    string_idx = @start_idx + 1

    @children.each_with_index do |child, child_idx|

      if child.class == self.class
        child.process_children(string)
        process_subresult(child.result)
        string_idx = child.close_idx + 1
      else
        si_unit = string[string_idx..child[:idx]-1]
        si_unit_counterpart = SI_UNIT_COUNTERPARTS[si_unit]

        process_operation(si_unit_counterpart, child_idx)
        string_idx = child[:idx] + 1
      end
    end


    add_final_unit(string, string_idx)

    @result[:units_array] << ')'
  end

  private

  def add_final_unit(string, string_idx)
    si_unit = string[string_idx..@close_idx-1]
    si_unit_counterpart = SI_UNIT_COUNTERPARTS[si_unit]

    process_operation(si_unit_counterpart, @children.length-1, true) unless si_unit_counterpart.nil?
  end

  # Updates the result after computing a subresult (nested parenthesis group).
  # Inputs:
  # => subresult: hash containing multiplication_factor and units_array keys,
  # => child_idx: integer representing the index of the subresult child in the
  #               @children array.
  def process_operation(si_unit_counterpart, child_idx, last = false)
    if si_unit_counterpart
      if should_be_multiplied?
        @result[:factor] *= si_unit_counterpart[:factor]
      else
        @result[:factor] /= si_unit_counterpart[:factor]
      end

      @result[:units_array] << si_unit_counterpart[:unit]
    end
    child = @children[child_idx]
    @result[:units_array] << child[:operator] unless child.nil? || last
  end

  # Updates the result after computing a subresult (nested parenthesis group).
  # Inputs:
  # => subresult: hash containing multiplication_factor and units_array keys,
  # => child_idx: integer representing the index of the subresult child in the
  #               @children array.
  def process_subresult(subresult)
    if should_be_multiplied?
      @result[:factor] *= subresult[:factor]
    else
      @result[:factor] /= subresult[:factor]
    end

    @result[:units_array].concat(subresult[:units_array])
  end

  # Determines whether the result[:factor] should be multiplied based on whether
  #   there is a preceeding operator, and if so, whether the preceeding operator
  #   is a parenthece or multiplication sign.
  def should_be_multiplied?
    ["*", "(", ")"].include?(@result[:units_array].last)
  end
end
