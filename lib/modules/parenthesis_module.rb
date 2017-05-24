require_relative '../helper_classes/parenthesis_group'

# Methods used in parsing a units string that has parenthesis.
module ParenthesisModule
  # Parses a units string that has parenthesis.
  def parse_complex_string
    @operator_objects = []
    @result_object = {factor: 1.0, units_array: []}
    string_idx = 0

    # Get top level operators and parenthesis groups.
    find_operators_and_parenthesis

    # Loop over top level operators and parenthesis groups, and appropriately
    #   update the @result_object.
    @operator_objects.each_with_index do |operator_obj, operator_idx|
      # For parenthesis groups.
      if operator_obj.class == ParenthesisGroup
        operator_obj.process_children(@string)

        add_subresult(operator_obj.result)
        string_idx = operator_obj.close_idx + 1

      # For * and / operators.
      else
        si_unit = @string[string_idx..operator_obj[:idx]-1]
        si_unit_counterpart = SI_UNIT_COUNTERPARTS[si_unit]
        add_si_unit_counterpart(si_unit_counterpart, operator_obj)

        string_idx = operator_obj[:idx] + 1
      end
    end

    add_final_unit(string_idx)
  end

  # Handles the last update to the @result_object if there is a unit trailing the
  #   last operator.
  # Input:
  # => string_idx: integer that should be the index of the last operator + 1.
  def add_final_unit(string_idx)
    si_unit = @string[string_idx..@string.length-1]
    si_unit_counterpart = SI_UNIT_COUNTERPARTS[si_unit]

    add_si_unit_counterpart(si_unit_counterpart)
  end

  # Adds a subresult (parenthese group) to the main result.
  # Input:
  # => subresult: hash with :factor and :units_array keys
  def add_subresult(subresult)
    if @result_object[:units_array].last.nil? || ["*", "(", ")"].include?(@result_object[:units_array].last)
      @result_object[:factor] *= subresult[:factor]
    else
      @result_object[:factor] /= subresult[:factor]
    end

    @result_object[:units_array].concat(subresult[:units_array])
  end

  # Populates @operator_objects array with top level operators, aka non-nested
  #   operators and parenthesis groups
  def find_operators_and_parenthesis
    parenthesis_arr = []

    @string.each_char.with_index do |char, idx|
      if char == "*" || char == "/"
        new_operator = {idx: idx, operator: char, type: :operator}

        # Add new operator to top level operator objects array if there are no
        #   open parenthesis objects.
        @operator_objects << new_operator if parenthesis_arr.empty?

        # Add child to open parenthesis object if there is one.
        parenthesis_arr.last.add_child(new_operator) if !parenthesis_arr.empty?
      elsif char == "("
        parenthesis_obj = ParenthesisGroup.new(idx)

        # Add parenthesis object to top level operator objects array if there
        #   are no open parenthesis objects.
        @operator_objects << parenthesis_obj if parenthesis_arr.empty?

        # Add child to open parenthesis object if there is one.
        parenthesis_arr.last.add_child(parenthesis_obj) if !parenthesis_arr.empty?

        # Add new open parenthesis object to array to account for following
        #   operators that come up before the new open parenthesis object is closed.
        parenthesis_arr << parenthesis_obj
      elsif char == ")"
        # Remove the last parenthesis object from the parenthesis array and close
        #   it off.
        parenthesis_obj = parenthesis_arr.pop
        parenthesis_obj.set_close_idx(idx)
      end
    end
  end
end
