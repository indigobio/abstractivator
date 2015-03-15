require 'active_support/core_ext/object/deep_dup'
require 'abstractivator/trees/block_collector'
require 'sourcify'
require 'delegate'
require 'set'

module Abstractivator
  module Trees

    # Transforms a tree at certain paths.
    # The transform is non-destructive and reuses untouched substructure.
    # For efficiency, it first builds a "path_tree" that describes
    # which paths to transform. This path_tree is then used as input
    # for a data-driven algorithm.
    def tree_map(h)
      raise ArgumentError.new('Must provide a transformer block') unless block_given?
      config = BlockCollector.new
      yield(config)
      TransformTreeClosure.new.do_obj(h, config.get_path_tree)
    end

    class TransformTreeClosure
      def initialize
        @bias = 0 # symbol = +, string = -
        @no_value = Object.new
      end

      def do_obj(obj, path_tree)
        case obj
          when nil; nil
          when Array; do_array(obj, path_tree)
          else; do_hash(obj, path_tree)
        end
      end

      private

      def do_hash(h, path_tree)
        h = h.dup
        path_tree.each_pair do |name, path_tree|
          if leaf?(path_tree)
            if hash_name = try_get_hash_name(name)
              hash_name, old_fh = get_key_and_value(h, hash_name)
              unless old_fh == @no_value || old_fh.nil?
                h[hash_name] = old_fh.each_with_object(old_fh.dup) do |(key, value), fh|
                  fh[key] = path_tree.call(value.deep_dup)
                end
              end
            elsif array_name = try_get_array_name(name)
              array_name, value = get_key_and_value(h, array_name)
              h[array_name] = value.map(&:deep_dup).map(&path_tree) unless value == @no_value || value.nil?
            else
              name, value = get_key_and_value(h, name)
              h[name] = path_tree.call(value.deep_dup) unless value == @no_value
            end
          else # not leaf
            name, value = get_key_and_value(h, name)
            h[name] = do_obj(value, path_tree) unless value == @no_value
          end
        end
        h
      end

      def leaf?(path_tree)
        path_tree.respond_to?(:call)
      end

      def get_key_and_value(h, string_key)
        tried_symbol = @bias >= 0
        trial_key = tried_symbol ? string_key.to_sym : string_key
        value = try_fetch(h, trial_key)

        if value == @no_value # failed
          @bias += (tried_symbol ? -1 : 1)
          key = tried_symbol ? string_key : string_key.to_sym
          [key, try_fetch(h, key)]
        else
          @bias += (tried_symbol ? 1 : -1)
          [trial_key, value]
        end
      end

      def try_fetch(h, trial_key)
        h.fetch(trial_key, @no_value)
      end

      def do_array(a, path_tree)
        a.map{|x| do_obj(x, path_tree)}
      end

      def try_get_hash_name(p)
        p =~ /(.+)\{\}$/ ? $1 : nil
      end

      def try_get_array_name(p)
        p =~ /(.+)\[\]$/ ? $1 : nil
      end
    end
  end
end
