module Abstractivator
  # Like an array
  class Slice
    include Enumerable

    def initialize(enum, a=nil, b=nil)
      @arr = enum.to_a
      @a = a || 0
      @b = b || @arr.size
    end

    def each(&block)
      en = Enumerator.new do |y|
        (@a...@b).each do |i|
          y << @arr[i]
        end
      end
      if block
        en.each(&block)
      else
        en
      end
    end

    def size
      @b - @a
    end

    def drop(n)
      Slice.new(@arr, [@a + [n, 0].max, @b].min, @b)
    end

    def [](idx)
      i = absolute_index(idx)
      i && @arr[i]
    end

    # def []=(idx, value)
    #   i = absolute_index(idx)
    #   if i.nil?
    #     raise 'cannot assign past end of slice'
    #   end
    #   @arr[i] = value
    # end

    def shift
      head = @arr[@a]
      @a = [@a + 1, @b].min
      head
    end

    private

    def absolute_index(rel_idx)
      if rel_idx >= 0
        if @a + rel_idx < @b
          @a + rel_idx
        else
          nil
        end
      else
        if @b + rel_idx >= @a
          @b + rel_idx
        else
          nil
        end
      end
    end
  end
end
