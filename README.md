# SI Unit Converter - Rails API Application

[SI Unit Converter live][heroku]

[heroku]: https://si-unit-converter.herokuapp.com/

## Setup Notes
1. Run `bundle install` to install the gem files.
2.  If you want to run `RSpec` tests `rake db:create` to create an empty `PostgreSQL` database - I could not seem to avoid a database when hosting the application on `Heroku`.
3. Run `bundle exec rspec` to execute test suite.  There are 3 test files in the spec folder: `units/si_controller_spec.rb`, `lib/conversions_spec.rb`, and `lib/si_unit_string_spec.rb`, the last of which contains all of the application logic tests.

## Rules
Cross-domain requests have been enabled for the `/units/si` route, so requests can be made from applications like `Postman`.

Units are not simplified in this application, so you will have things like `kg/kg` and `kg*kg`.

Units are case sensitive, `KG` will not be recognized as `kg`.

White spaces are removed in this implementation.

All units and parenthesis groupings should be separated by `*` or `/` symbols. Strings such as `kg(ha/min)` will not be interpreted as `kg*(ha/min)`.

## Description
This application accepts a string containing a variety of units that can be multiplied, divided, and grouped with parenthesis.  The accepted units and symbols can be seen in this object:

```JavaScript
SI_UNIT_COUNTERPARTS = {
  "minute" => { unit: "s", factor: 60 },
  "min" => { unit: "s", factor: 60 },
  "hour" => { unit: "s", factor: 3600 },
  "h" => { unit: "s", factor: 3600 },
  "day" => { unit: "s", factor: 86400 },
  "d" => { unit: "s", factor: 86400 },
  "degree" => { unit: "rad", factor: Math::PI/180 },
  "°" => { unit: "rad", factor: Math::PI/180 },
  "'" => { unit: "rad", factor: Math::PI/10800 },
  "second" => { unit: "rad", factor: Math::PI/648000 },
  "\"" => { unit: "rad", factor: Math::PI/648000 },
  "hectare" => { unit: "m^2", factor: 10000 },
  "ha" => { unit: "m^2", factor: 10000 },
  "litre" => { unit: "m^3", factor: 0.001 },
  "L" => { unit: "m^3", factor: 0.001 },
  "tonne" => { unit: "kg", factor: 10**3 },
  "t" => { unit: "kg", factor: 10**3 }
}
```

The provided units string is then converted to standard SI units, and an object containing a `multiplication factor` and the SI `units` is returned.

The API is queried via the `/units/si` route.  For example, a GET request to

`"/units/si?units=degree/minute"`

will result in

`{ “unit_name”: "rad/s", “multiplication_factor”: 0.00029088820867 }`.

## Implementation Details
I developed this application with the goal of being able to handle different edge cases such as nested parenthesis, empty strings, empty parenthesis, etc.  These tests can be seen in `spec/lib/si_unit_string_spec.rb`.

The main logic for this application takes place in the `lib/si_unit_string.rb` file.  The `SIUnitString` class includes two modules, a `NoParenthesisModule` and a `ParenthesisModule` located in the `lib/modules` folder.  The unit conversion data is in the `SI_UNIT_COUNTERPARTS` hash inside `lib/conversions.rb`.

I first developed a process for handling input strings that have no parenthesis, hence the `NoParenthesisModule`.  Next I developed the `ParenthesisModule` for handling strings that do have parenthesis.  In the end, the `ParenthesisModule` method `#parse_complex_string` can handle both strings with and without parenthesis, but I chose to leave the `NoParenthesisModule` method `#parse_simple_string` since I had already written it, and I thought it was easy to follow.

The `parse_simple_string` method is fairly simple, adding converted units and operators to a `units_array` and applying the appropriate operation to the `multiplication_factor` based on whether the last `operator` in the `units_array` was a `*` or `/` symbol.

The `parse_complex_string` method uses a `ParenthesisGroup` class found in `lib/helper_classes/parenthesis_group.rb`.  The `ParenthesisGroup` class has a `children` array instance variable that holds all the operators and other parenthesis groups that belong inside it.  It then has a `parse` method that handling operators normally, and calls the `parse` method of nested parenthesis groupings before appropriately modifying its own `multiplication_factor` and `units_array`.
