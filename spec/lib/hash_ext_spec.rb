require 'rspec'
require 'abstractivator/hash_ext'
require 'active_support/core_ext/object/deep_dup'

describe 'Hash extensions' do
  describe '#deep_map' do
    it 'deeply maps non-hash, non-array values' do
      orig = {
        a: 1,
        b: [
             2,
             {c: 3}
           ],
        d: {
          e: 4
        }
      }
      input = orig.deep_dup
      expected_output = {
        a: '1',
        b: [
             '2',
             {c: '3'}
           ],
        d: {
          e: '4'
        }
      }
      actual_output = input.deep_map(&:to_s)
      expect(actual_output).to eql expected_output
      expect(input).to eql orig
    end
  end
end
