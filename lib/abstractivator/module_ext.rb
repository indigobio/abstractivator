class Module
  # useful in the following scenario:
  #   things.select(&:Array.type?)
  # instead of:
  #   things.select { |x| x.is_a?(Array) }
  def type?
    proc { |x| x.is_a?(self) }
  end
end
