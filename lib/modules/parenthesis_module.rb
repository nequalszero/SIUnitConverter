require_relative '../helper_classes/parenthesis_group'

module ParenthesisModule
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
