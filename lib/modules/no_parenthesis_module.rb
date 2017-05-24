# Methods for parsing a units string that has no parenthesis.
module NoParenthesisModule
  # Returns a hash with 2 keys:
  # =>  factor (float), and
  # =>  units_array (array of strings with units and operators)
  def parse_simple_string
    @operator_objects = []
    @result_object = {factor: 1.0, units_array: []}
    find_operators

    start_idx = 0

    @operator_objects.each do |operator_obj|
      si_unit = @string[start_idx..operator_obj[:idx]-1]
      si_unit_counterpart = SI_UNIT_COUNTERPARTS[si_unit]

      add_si_unit_counterpart(si_unit_counterpart, operator_obj)
      start_idx = operator_obj[:idx] + 1
    end

    si_unit = @string[start_idx..-1]
    si_unit_counterpart = SI_UNIT_COUNTERPARTS[si_unit]
    add_si_unit_counterpart(si_unit_counterpart)

    @result_object
  end

  # Adds an SI unit counterpart to the @result_object[:units_array], and modifies the
  #   @result_object[:factor] appropriately if the last item in the :units_array
  #   was a '*' or '/' sign.  It also adds the next operator object if one is provided.
  #   If the SI unit counterpart is nil, only the operator object will be added.
  # Inputs:
  # => si_unit_counterpart: {unit: <string>, factor: <integer or float>}, and
  # => operator_obj: (optional) hash of form {idx: <integer>, operator: "*" or "/"}
  def add_si_unit_counterpart(si_unit_counterpart, operator_obj = nil)
    # handles the first unit of a string
    unless si_unit_counterpart.nil?
      if @result_object[:units_array].empty?
        @result_object[:factor] *= si_unit_counterpart[:factor]
      # handles subsequent units preceded by operators
      elsif ["*", "/"].include?(@result_object[:units_array].last)
        @result_object[:factor] *= si_unit_counterpart[:factor] if @result_object[:units_array].last == "*"
        @result_object[:factor] /= si_unit_counterpart[:factor] if @result_object[:units_array].last == "/"
      end
    end

    @result_object[:units_array] << si_unit_counterpart[:unit] unless si_unit_counterpart.nil?
    @result_object[:units_array] << operator_obj[:operator] unless operator_obj.nil?
  end

  # Used for simple string with no parenthesis.
  # Finds all * and / signs within a string.
  # Returns an array of hashes of form {idx: <integer>, operator: "*" or "/"}
  def find_operators
    @string.each_char.with_index do |char, idx|
      @operator_objects << {idx: idx, operator: char} if char == "*" || char == "/"
    end
  end
end
