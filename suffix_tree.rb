#!/usr/bin/env ruby

require 'yaml'

class NilClass
  def name
    "nil"
  end
end

class Array
  def name
    @name ||= (
      if self[1]
        #puts self.inspect
        range =  self[1][2].to_a.find{|k,v| v[1].object_id==self.object_id}[1][0]
        self[1].name + $text[range[0]...range[1]]
      else
        if self[2].is_a?(Proc)
          "&"
        else
          "$"
        end
      end
    )
  end
end

require 'pry'

class SuffixTree

  # node =  [ suffix_link, parent, edges  ]
  # edges = { first_char => edge }
  # edge =  [ range, node ]
  # range = [ first, last ] # corresponds to interval  [ first, last )

  def initialize(text)
    $text = @text = text
    @joker_edge = [[0,1]]
    @joker = [nil, nil, lambda{|c| @joker_edge}]
    @root = [@joker, nil, {}]
    @joker_edge << @root
    @infty = @text.size
    build_tree(@root, 0, @infty)
  end

  def build_tree(node, n, infty, skip=0)
    #puts "ENTER #{[node.name, @text[n...infty]].inspect}"
    while n < infty
      puts "-----------------------"
      pp(@root)
      #puts "SEARCH #{@text[n...infty]} FROM #{node.name}"
      c = @text[n]
      edges = node[2]
      if edge = edges[c]
        first,last = edge[0]
        i,n0 = first,n
        can_skip = [skip, last-first].min
        i += can_skip
        n += can_skip
        skip -= can_skip
        while i < last && n < infty && (@text[i]==@text[n] || edge==@joker_edge)
          i += 1; n += 1
        end

        if i == last
          # came to the next node
          puts "NEXT NODE #{@text[n0...n]}+#{@text[n...infty]}:  #{node.name} -> #{edge[1].name}"
          node = edge[1]
        else
          # splitting edge
          puts "SPLIT EDGE (#{@text[(0...n0)]},#{@text[(n0...n)]},#{@text[(n...@infty)]})  #{@text[ (first...last)]} = #{@text[ (first...i)]}+#{@text[ (i...last)]} "
          middle_node = [ nil, node, {@text[i] => edge} ]
          edge_to_middle = [ [first, i], middle_node ]
          edges[c] = edge_to_middle
          edge[0][0] = i
          edge[1][1] = middle_node
          node = build_tree(node[0], n0, n, i - first)
          middle_node[0] = node
          node = middle_node
        end
      else
        # no way to go; creating leaf
        new_leaf = [ nil,  node, {} ]
        edges[c] = [ [n, @infty], new_leaf ]
        puts "CREATE LEAF (#{@text[(n...@infty)]}). #{node.name} -> #{node[0].name}"
        node = node[0]
      end
    end
    #puts "OUT #{node.name}"
    node
  end

  # pretty print
  def pp(node=nil, indent = 0)
    node ||= @root
    space = "    " * indent
    puts  space + "ID    : #{node.name}"
    puts  space + "link  : #{node[0].name}"
    # puts  space + "parent: #{node[1].name}"
    puts  space + "edges : "
    if node == @joker
      puts  space + "  — JOKER"
    else
      node[2].each do |k,v|
        puts  space + "  -#{k.to_i.chr} [#{v[0][0]},#{v[0][1]})=#{@text[ v[0][0]...v[0][1] ] }:"
        pp(v[1], indent + 1)
      end
    end
  end

  def search(word)
    node = @root
    n = 0
    infty = word.size
    i = 0
    while n < infty
      edges = node[2]
      c = word[n]
      if edge = edges[ c ]
        i,last = edge[0]
        while @text[i] == word[n] && n < infty && i < last
          i += 1; n += 1
        end
        if i == last
          node = edge[1]
        else
          break
        end
      else
        break
      end
    end
    n == infty ?  i - infty : nil
  end
end

# text = "abrababb"
# tree = SuffixTree.new(text)
# tree.pp
