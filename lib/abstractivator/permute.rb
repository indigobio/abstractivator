module Abstractivator
  module Permute
    def permute(vars={}, &block)
      return [] if vars.empty?
      block ||= proc { |**kws| kws.values }
      perm(vars.each_pair.map{|k, v| [k, v.to_a]}, {}, &block)
    end

    private

    def perm(vars, env, &block)
      var, vals = vars.first
      if vars.size == 1
        vals.map { |val| block.call(**env.merge(var => val)) }
      else
        vals.flat_map { |val| perm(vars.drop(1), env.merge(var => val), &block) }
      end
    end

    extend self
  end
end
