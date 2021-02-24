
struct Path
    nodes::Vector{Node}
    edges::Vector{Edge}
end


function get_node(p::Path, idx::Int)
    return p.nodes[idx]
end


function get_relationship(p::Path, idx::Int)
    return p.edges[idx]
end


function first_node(p::Path)
    return p.nodes[1]
end


function last_node(p::Path)
    return p.nodes[nodes_count(p)]
end


function edge_count(p::Path)
    return length(p.edges)
end


function nodes_count(p::Path)
    return length(p.nodes)
end
