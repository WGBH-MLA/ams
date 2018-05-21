# Return TRUE if expected_prepnded_module comes before prepending_class in
# the prepending_class's ancestor list.
RSpec::Matchers.define :have_prepended do |expected_prepended_module|
  match do |prepending_class|
    prepending_class.ancestors.index(prepending_class) > prepending_class.ancestors.index(expected_prepended_module)
  end
end
