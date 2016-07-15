require 'abstractivator/permute'
require 'abstractivator/hash_ext'

module Abstractivator
  # Creates permutations of a hash.
  #
  # Special values within the hash specify how to permute.
  #   FixedRange specifies a list of values.
  #   SteppedRange specifies an interpolation between two values.
  #
  # For efficiency, the input hash is used to create a proc that
  # constructs an instance of the hash given a set of permuted values.
  # Permute#permute is used to generate all possible sets of values.
  module HashPermuter
    include Permute

    FixedRange = Struct.new(:values)
    class FixedRange
      def range_values
        values.to_a
      end
    end

    SteppedRange = Struct.new(:min, :max, :num_steps)
    class SteppedRange
      def range_values
        step_size = (max - min) / (num_steps - 1.0)
        (min..max).step(step_size).to_a
      end
    end

    def permute_hash(hash)
      vars, template = templatize(hash)
      permute(vars, &hash_constructor(template, vars.keys))
    end

    private

    FreeVar = Struct.new(:name)
    class FreeVar
      def inspect
        name
      end
    end

    def templatize(hash)
      vars = {}
      template = hash.deep_map do |v|
        if v.respond_to?(:range_values)
          name = HashPermuter.new_identifier
          vars[name] = v.range_values
          FreeVar.new(name)
        else
          v
        end
      end
      [vars, template]
    end

    def hash_constructor(template, var_names)
      params = var_names.map { |v| "#{v}:" }.join(', ')
      eval("proc { |#{params}| #{template.inspect} }")
    end

    def self.new_identifier
      n = 0
      (@new_identifier ||= proc { :"t#{n += 1}" }).call
    end

    extend self
  end
end
