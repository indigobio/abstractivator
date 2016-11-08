module Abstractivator
  module Sort
    def deep_sort_hash(obj)
      case obj
      when Hash
        obj.sort.each_with_object({}) do |(k, v), a|
          a[k] = deep_sort_hash(v)
        end
      when Array
        obj.map(&method(:deep_sort_hash))
      else
        obj
      end
    end
  end
end
