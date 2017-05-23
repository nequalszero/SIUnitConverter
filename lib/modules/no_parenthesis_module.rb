module NoParenthesisModule
  # Returns a hash with 2 keys:
  # =>  factor (float), and
  # =>  units_array (array of strings with units and operators)
  def parse_simple_string
    @operator_objects = []
    result = {factor: 1.0, units_array: []}
    find_operators

    start_idx = 0

    @operator_objects.each do |operator_obj|
      si_unit = @string[start_idx..operator_obj[:idx]-1]
      si_unit_counterpart = SI_UNIT_COUNTERPARTS[si_unit]

      add_si_unit_counterpart(result, si_unit_counterpart, operator_obj)
      start_idx = operator_obj[:idx] + 1
    end

    si_unit = @string[start_idx..-1]
    si_unit_counterpart = SI_UNIT_COUNTERPARTS[si_unit]
    add_si_unit_counterpart(result, si_unit_counterpart)

    result
  end

  # Used for simple string with no parenthesis.
  # Finds all * and / signs within a string.
  # Returns an array of hashes of form {idx: <integer>, operator: "*" or "/"}
  def find_operators
    @string.each_char.with_index do |char, idx|
      @operator_objects << {idx: idx, operator: char} if char == "*" || char == "/"
    end
    @operator_objects
  end
end
