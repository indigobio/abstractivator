require 'rspec'
require 'abstractivator/module_ext'

describe 'module extensions' do
  describe '#type' do
    it 'returns a predicate that evaluates whether a value is_a? <this type>' do
      p = Enumerable.type?
      expect(p.call([])).to be true
      expect(p.call({})).to be true
      expect(p.call(nil)).to be false
      expect(p.call(1)).to be false
    end
  end
end
