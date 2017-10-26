class SuffixTree

  # node =  [ suffix_link, parent, edges  ]
  # edges = { first_char => edge }
  # edge =  [ range, target_node ]
  # range = [ first, last ] # corresponds to interval  [ first, last )

  def initialize(text)
    @text = text
    @joker_edge = [[0,1]] # empty interval
    @joker = [nil, nil, lambda{|c| @joker_edge}]
    @root = [@joker, nil, {}]
    @joker_edge << @root
    @infty = @text.size
    build_tree(@root, 0, @infty)
  end

  private

  def build_tree(node, n, infty, skip=0)
    while n < infty
      c = @text[n]
      edges = node[2]
      if edge = edges[c]
        first,last = edge[0]
        i,n0 = first,n
        (can_skip = [skip, last-first].min
        i += can_skip
        n += can_skip
        skip -= can_skip) if skip > 0
        while i < last && n < infty && (@text[i] == @text[n] || edge.equal?(@joker_edge))
           i += 1; n += 1
        end
        if i == last
          # came to the next node
          node = edge[1]
        else
          # splitting edge
          middle_node = [ nil, node, {@text[i] => edge} ]
          edge_to_middle = [ [first, i], middle_node ]
          edges[c] = edge_to_middle
          edge[0][0] = i
          edge[1][1] = middle_node
          middle_node[0] = build_tree(node[0], n0, n, i-first)
          node = middle_node
        end
      else
        # no way to go; creating leaf
        new_leaf = [ nil,  node, {} ]
        edges[c] = [ [n, @infty], new_leaf ]
        node = node[0]
      end
    end
    node
  end
end
