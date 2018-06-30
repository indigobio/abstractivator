require 'rspec'
require 'abstractivator/slice'

module Abstractivator
  describe Slice do
    it 'enumerates' do
      s = Slice.new([1,2,3])
      expect(s.to_a).to eql [1,2,3]
      expect(s.each.to_a).to eql [1,2,3]
      expect(s.reverse_each.to_a).to eql [3,2,1]
      expect(s.map(&:to_s)).to eql %w(1 2 3)
    end
    it 'responds to #size' do
      s = Slice.new([1,1,1])
      expect(s.size).to eql 3
    end
    it 'drops' do
      s = Slice.new([1,2,3])
      expect(s.drop(-1).to_a).to eql [1,2,3]
      expect(s.drop(0).to_a).to eql [1,2,3]
      expect(s.drop(1).to_a).to eql [2,3]
      expect(s.drop(2).to_a).to eql [3]
      expect(s.drop(3).to_a).to eql []
      expect(s.drop(4).to_a).to eql []
    end
    it 'shifts' do
      s = Slice.new([1,2,3])
      expect(s.shift).to eql 1
      expect(s.shift).to eql 2
      expect(s.shift).to eql 3
      expect(s.shift).to eql nil
    end
    it 'indexes' do
      s = Slice.new([1,2,3])
      expect(s[0]).to eql 1
      expect(s[1]).to eql 2
      expect(s[2]).to eql 3
      expect(s[4]).to eql nil
      expect(s[-1]).to eql 3
      expect(s[-2]).to eql 2
      expect(s[-3]).to eql 1
      expect(s[-4]).to eql nil
    end
    # it 'assigns indexes' do
    #   s = Slice.new([1,2,3])
    #   s[0] = 8
    #   expect(s.to_a).to eql [8,2,3]
    #   s[-1] = 9
    #   expect(s.to_a).to eql [8,2,9]
    # end
  end
end
