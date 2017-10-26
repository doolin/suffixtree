#!/usr/bin/env ruby

require 'rspec/autorun'

require_relative 'suffix_tree'

RSpec.describe SuffixTree do
  describe '.new' do
    xit 'instantiates' do
      expect(SuffixTree.new('banana')).not_to be nil
    end

    it 'builds a tree from "a"' do
      tree = SuffixTree.new('aba')
      expect(tree).to eq nil
    end
  end

  describe '#search' do
    it 'finds a string' do
      string = 'abcdcdbd'
      tree = SuffixTree.new(string)
      position = tree.search('cd')
      expect(position).to eq 2
    end
  end
end
