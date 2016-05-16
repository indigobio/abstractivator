require 'abstractivator/proc_ext'

module Abstractivator
  # A transparent wrapper for delaying evaluation.
  # Usage: v = lazy { 1 + 2 }
  # This delays the addition until the value is actually needed,
  # i.e., a method is called on it.
  # The wrapper is "transparent" in that it acts as much as possible
  # like the wrapped object itself. For example:
  # lazy { 42 }.class  ==>  Fixnum
  # Don't use this for mission critical code.
  # Don't pass lazy objects across API boundaries.
  class Lazy < BasicObject
    def initialize(&make)
      @make = make
    end

    def __lazy_ensure_obj
      if @make
        @obj = @make.call
        @make = nil
      end
      @obj
    end
    private :__lazy_ensure_obj

    def method_missing(method, *args, **kws, &block)
      __lazy_ensure_obj.proxy_send(method, *args, **kws, &block)
    end

    def ==(other)
      __lazy_ensure_obj == other
    end

    def !=(other)
      __lazy_ensure_obj != other
    end

    def !
      !__lazy_ensure_obj
    end

    # Force ruby to delegate to wrapped object.
    # Ruby's C implementation makes assumptions about object type.
    # This is required for implicit array coercion:
    #   a = [1, 2]
    #   x, y = a
    def to_ary
      __lazy_ensure_obj
      if @obj.respond_to?(:to_ary)
        @obj.to_ary
      else
        nil
      end
    end

    # Force ruby to delegate to wrapped object.
    # Ruby's C implementation makes assumptions about object type.
    # This is required for explicit array coercion:
    #   x = 1
    #   a = *x
    #   (a == [1])
    def to_a
      __lazy_ensure_obj
      if @obj.respond_to?(:to_a)
        @obj.to_a
      else
        nil
      end
    end

    def inspect
      "#<Abstractivator::Lazy:#{@make ? '' : @obj.class.name + ':'}0x#{__id__.to_s(16).rjust(8, '0')}>"
    end
  end
end

module Kernel
  def lazy(&block)
    Abstractivator::Lazy.new(&block)
  end
end

class Module
  # To enable case/when support, reimplement Module#===
  # so it goes through our method_missing mechanism.
  # See https://github.com/ruby/ruby/blob/v2_3_0/object.c#L1534
  def ===(obj)
    obj.is_a?(self)
  end
end
