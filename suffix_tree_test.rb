#!/usr/bin/env ruby

require_relative 'suffix_tree'

chars = "qwertyuiopasdfghjklzxcvbnm,./'][;1234567890".split(//)

require 'benchmark'

Benchmark.bmbm do |b|
  [2, 3, 40].each do |alpha_size|
    [5, 10, 20].each do |i|
      n = 100 * i
      text = ""
      n.times{ text << chars[rand(alpha_size)] }
      text = text + text.reverse + text
      b.report("#{text.size}-#{alpha_size}") do
        SuffixTree.new(text)
      end
    end
  end
end

require 'test/unit'

class TestSuffixTree < Test::Unit::TestCase
  def test_simple
    text = "abrakadabraababaabbrrakadabkakadabrabrkadbkadabraaaaz"
    tree = SuffixTree.new(text)
    tree.search( "abra" )
    assert( tree.search( "" ) )
    assert( tree.search( text[(7..12)] ) )
    assert( tree.search( text[(3..12)] ) )
    assert( tree.search( text[(3..22)] ) )
    assert( tree.search( text[(21..22)] ) )
    assert( tree.search( "abrakadaa" ) == nil )
    assert( tree.search( text ) )
  end

  def test_small_strings
    [
      "a",
      "aaaaaaa",
      "azazaz",
      "abcabc",
      "abrababb",
      "abraabaabb",
      "azazazaza",
      "aaaaaaaaaaaaaaaaaaaa",
      "aaaaaaaaaaaaaaaaaaaaz",
      "zaaaaaaaaaaaaaaaaaaaa",
      "aaaaaaazaaaaaaaaaaaa",
      "aaaaaaazaaaaazaaaaaa",
      "abrakadabraababaabbrrakadabkakadabrabrkadbkadabraaaa",
      "abrakadabraababaabbrrakadabkakadabrabrkadbkadabraaaaz"
    ].each do |text|
      tree = SuffixTree.new(text)
      (1..text.size).each do |length|
        (0...text.size-length).each do |i|
          word = text[ (i...i+length) ]
          assert( text[tree.search(word).to_i, word.length] == word,
                   "Searching for #{word} in #{text}" )
        end
      end
    end
  end
end
