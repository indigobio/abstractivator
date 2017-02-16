# like Enumerable#map, except if the receiver is not enumerable,
# i.e., a single value, then it transforms the single value.

class Array
  alias_method :value_map, :map
end

class NilClass
  def value_map
    nil
  end
end

class Object
  def value_map
    yield self
  end
end
