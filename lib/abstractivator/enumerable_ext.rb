require 'set'
require 'abstractivator/proc_ext'

module Enumerable

  # joins items from left with items from right based on their keys.
  # get_{left,right}_key are callables which, given an item, return the item's key.
  # the defaults are used to form a pair for items which have no match.
  # returns an array of 2-element arrays, each of which is a left/right pair.
  def self.outer_join(left, right, get_left_key, get_right_key, left_default, right_default)

    ls = left.hash_map(get_left_key)
    rs = right.hash_map(get_right_key)

    raise 'duplicate left keys' if ls.size < left.size
    raise 'duplicate right keys' if rs.size < right.size

    result = []

    ls.each_pair do |k, l|
      r = rs[k]
      if r
        rs.delete(k)
      else
        r = get_default(right_default, l)
      end
      result.push [l, r]
    end

    rs.each_pair do |_, r|
      result.push [get_default(left_default, r), r]
    end

    result
  end

  def self.inner_join(left, right, get_left_key, get_right_key)
    sentinel = Object.new
    result = self.outer_join(left, right, get_left_key, get_right_key, sentinel, sentinel)
    result.reject { |pair| pair.first == sentinel || pair.last == sentinel }
  end

  def self.get_default(default, other_side_value)
    default.callable? ? default.call(other_side_value) : default
  end

  def self.proc?(x)
    x.respond_to?(:call)
  end

  def hash_map(get_key=->x{x}, &get_value)
    Hash[self.map{|x| [Proc.loose_call(get_key, [x]), get_value ? get_value.call(x) : x]}]
  end

  def outer_join(right, get_left_key, get_right_key, default_value)
    Enumerable.outer_join(self, right, get_left_key, get_right_key, default_value, default_value)
  end

  def inner_join(right, get_left_key, get_right_key)
    Enumerable.inner_join(self, right, get_left_key, get_right_key)
  end

  def uniq?
    seen = Set.new
    each_with_index do |x, i|
      seen << (block_given? ? yield(x) : x)
      return false if seen.size < i + 1
    end
    true
  end

  orig_detect = instance_method(:detect)
  define_method :detect do |*args, &block|
    detect = orig_detect.bind(self)

    if args.size == 1 && !args.first.callable? && block
      value = args.first
      detect.call {|x| block.call(x) == value}
    elsif args.size == 2 && !block
      attr_name, value = args
      detect.call {|x| x.send(attr_name) == value}
    else
      detect.call(*args, &block)
    end
  end

  def inject_right(*args, &block)
    self.reverse_each.inject(*args, &block) # reverse_each to avoid duplicating the enumerable, when possible
  end

  def pad_right(n, value=nil, &block)
    block ||= proc { value }
    self + ([n-self.size, 0].max).times.map(&block)
  end

  def stable_sort(&compare)
    compare = compare || ->(a, b){a <=> b}
    xis = self.each_with_index.map{|x, i| [x, i]}
    sorted = xis.sort do |(a, ai), (b, bi)|
      primary = compare.call(a, b)
      primary != 0 ? primary : (ai <=> bi)
    end
    sorted.map(&:first)
  end

  def select_map(&block)
    self.map(&block).select { |x| x }
  end

  def single
    if size != 1
      raise ArgumentError, "expected a single element but was: #{inspect}"
    end
    self.first
  end

  def unique_by(&block)
    self.group_by(&block).map { |_, vs| vs.first }
  end

  def duplicates(&block)
    group_by(&block)
      .select { |_, vs| vs.size > 1 }
      .map { |k, _| k }
  end

  # Folds over a cyclic graph. 'self' is the root node set.
  # Each node is visited once, in an unspecified order.
  # Node identity is determined by #object_id
  # @param init [Object] the initial accumulator
  # @param get_children_proc [Proc] takes a node and returns its children (or neighbors)
  # @yieldparam acc [Object] the accumulator
  # @yieldparam node [Object] the current node
  # @yieldreturn [Object] the accumulator, after visiting all nodes once
  def cyclic_fold(init, get_children_proc, &block)
    xs = self.dup
    seen = Set.new
    acc = init
    while xs.any?
      x = xs.shift
      if seen.include?(x.object_id)
        next
      else
        seen.add(x.object_id)
        acc = block.call(acc, x)
        xs.concat(get_children_proc.call(x))
      end
    end
    acc
  end
end
