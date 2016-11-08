require 'abstractivator/sort'

describe Abstractivator::Sort do
  include Abstractivator::Sort
  describe '#deep_sort_hash' do
    context 'when empty hash' do
      let(:hash) { {} }
      it 'returns empty hash' do
        expect_same_order(deep_sort, {})
      end
    end

    context 'when single level' do
      let(:hash) { {one: 1, two: '2', three: 3, four: '4'} }
      it 'returns new hash with the keys sorted alpha-numerically' do
        expected = {four: '4', one: 1, three: 3, two: '2'}
        expect_same_order(deep_sort, expected)
      end
    end

    context 'when mult-level hash' do
      let(:hash) { {one: 1, two: {three: {four: '4', five: 5}}, six: 6} }
      it 'returns new hash with the keys sorted alpha-numerically' do
        expected = {one: 1, six: 6, two: {three: {five: 5, four: '4'}}}
        expect_same_order(deep_sort, expected)
      end
    end

    context 'when contains an array' do
      let(:hash) { {one: 1, two: [{three: {four: '4', five: 5}}, 'six', :seven], eight: 8} }
      it 'returns new hash with the keys sorted alpha-numerically (does not sort arrays)' do
        expected = {eight: 8, one: 1, two: [{three: {five: 5, four: '4'}}, 'six', :seven]}
        expect_same_order(deep_sort, expected)
      end
    end

    def deep_sort
      deep_sort_hash(hash)
    end

    def expect_same_order(actual, expected)
      case actual
      when Hash
        expect(actual.keys).to eql expected.keys
        expect_same_order(actual.values, expected.values)
      when Array
        expect(actual.size).to eql expected.size
        actual.zip(expected).each { |a, e| expect_same_order(a, e) }
      else
        expect(actual).to eql expected
      end
    end
  end
end
