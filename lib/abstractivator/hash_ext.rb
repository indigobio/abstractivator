class Hash
  def deep_map(&block)
    Hash.deep_map(self, &block)
  end

  def self.deep_map(x, &block)
    case x
    when Hash
      x.each_with_object(x.dup) do |(k, v), x|
        x[k] = deep_map(v, &block)
      end
    when Array
      x.map { |v| deep_map(v, &block) }
    else
      block.call(x)
    end
  end
end
