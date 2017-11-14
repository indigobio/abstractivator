# Like Enumerable#map, except if the receiver is not enumerable,
# i.e., a single value, then it transforms the single value.
#
# [2,3].value_map { |x| x * x }  =>  [4, 9]
# 2    .value_map { |x| x * x }  =>  4

class Array
  alias_method :value_map, :map
end

class Object
  def value_map
    yield self
  end
end
