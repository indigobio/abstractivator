require 'active_support/core_ext/object/deep_dup'
require 'abstractivator/trees/block_collector'
require 'abstractivator/proc_ext'
require 'delegate'
require 'set'

module Abstractivator
  module Trees

    SetMask = Struct.new(:items, :get_key)
    def set_mask(items, get_key)
      SetMask.new(items, get_key)
    end

    module Helpers
      refine Object do
        def hash_like?(x)
          x.respond_to?(:each_pair) && (x.respond_to?(:fetch) || x.respond_to?(:[]))
        end

        def array_like?(x)
          x.is_a?(Array) || (!x.is_a?(Struct) && x.is_a?(Enumerable))
        end
      end
    end

    module TypeComparer
      using Helpers

      def none
        proc { true }
      end

      def exact
        proc { |tree, mask| tree.class == mask.class }
      end

      def subtype
        # proc { |tree, mask| tree.is_a?(mask.class) }
        proc { |tree, mask| tree.is_a?(mask.class) || (mask.is_a?(Hash) && hash_like?(tree)) }
      end

      extend self
    end

    def tree_compare(tree, mask, type_comparer: nil)
      Comparer.new(type_comparer || TypeComparer.none).tree_compare(tree, mask)
    end

    class Comparer
      using Helpers

      attr_reader :type_comparer

      def initialize(type_comparer)
        @type_comparer = type_comparer
      end

      # Compares a tree to a mask.
      # Returns a diff of where the tree differs from the mask.
      # Ignores parts of the tree not specified in the mask.
      def tree_compare(tree, mask, path=[], index=nil)
        if mask == [:*] && tree.is_a?(Enumerable)
          []
        elsif mask == :+ && tree != :__missing__
          []
        elsif mask == :- && tree == :__missing__
          []
        elsif mask == :- && tree != :__missing__
          [diff(path, tree, :__absent__)]
        elsif mask.callable?
          are_equivalent = mask.call(tree)
          are_equivalent ? [] : [diff(path, tree, mask)]
        else
          if mask.is_a?(SetMask) # must check this before Enumerable because Structs are enumerable
            if array_like?(tree)
              # convert the enumerables to hashes, then compare those hashes
              tree_items = tree
              mask_items = mask.items.dup
              get_key = mask.get_key

              be_strict = !mask_items.delete(:*)
              new_tree = hashify_set(tree_items, get_key)
              new_mask = hashify_set(mask_items, get_key)
              tree_keys = Set.new(new_tree.keys)
              mask_keys = Set.new(new_mask.keys)
              tree_only = tree_keys - mask_keys

              # report duplicate keys
              if new_tree.size < tree_items.size
                diff(path, [:__duplicate_keys__, duplicates(tree_items.map(&get_key))], nil)
              elsif new_mask.size < mask_items.size
                diff(path, nil, [:__duplicate_keys__, duplicates(mask_items.map(&get_key))])
                # hash comparison allows extra values in the tree.
                # report extra values in the tree unless there was a :* in the mask
              elsif be_strict && tree_only.any?
                tree_only.map{|k| diff(push_path(path, k), new_tree[k], :__absent__)}
              else # compare as hashes
                tree_compare(new_tree, new_mask, path, index)
              end
            else
              [diff(path, tree, mask.items)]
            end
          elsif hash_like?(mask)
            if hash_like?(tree) && type_comparer.call(tree, mask)
              mask.each_pair.flat_map do |k, v|
                tree_compare(fetch(tree, k, :__missing__), v, push_path(path, k))
              end
            else
              [diff(path, tree, mask)]
            end
          elsif array_like?(mask)
            if array_like?(tree) && type_comparer.call(tree, mask)
              tree = tree.to_a
              mask = mask.to_a
              index ||= 0
              if !tree.any? && !mask.any?
                []
              elsif !tree.any?
                [diff(push_path(path, index.to_s), :__missing__, mask)]
              elsif !mask.any?
                [diff(push_path(path, index.to_s), tree, :__absent__)]
              else
                # if the mask is programmatically generated (unlikely), then
                # the mask might be really big and this could blow the stack.
                # don't support this case for now.
                tree_compare(tree.first, mask.first, push_path(path, index.to_s)) +
                    tree_compare(tree.drop(1), mask.drop(1), path, index + 1)
              end
            else
              [diff(path, tree, mask)]
            end
          else
            tree == mask && type_comparer.call(tree, mask) ? [] : [diff(path, tree, mask)]
          end
        end
      end

      private

      def fetch(hash_ish, key, default=nil, &block)
        if hash_ish.respond_to?(:fetch)
          hash_ish.fetch(key, default, &block)
        else
          hash_ish[key] || default || (block && block.call(key))
        end
      end

      def hashify_set(items, get_key)
        Hash[items.map{|x| [get_key.call(x), x] }]
      end

      def duplicates(xs)
        xs.group_by{|x| x}.each_pair.select{|_k, v| v.size > 1}.map(&:first)
      end

      def push_path(path, name)
        path + [name]
      end

      def path_string(path)
        path.join('/')
      end

      def diff(path, tree, mask)
        {path: path_string(path), tree: tree, mask: massage_mask_for_diff(mask)}
      end

      def massage_mask_for_diff(mask)
        if mask.callable?
          :__predicate__
        else
          mask
        end
      end
    end
  end
end
