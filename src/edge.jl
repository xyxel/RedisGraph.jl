struct Edge
    id::Union{Integer, Nothing}
    relation::String
    src_node::Union{Node, Integer}
    dest_node::Union{Node, Integer}
    properties::Dict
end

Edge(relation::String, src_node::Union{Node, Integer}, dest_node::Union{Node, Integer}, properties::Dict) = Edge(nothing, relation, src_node, dest_node, properties)
Edge(relation::String, src_node::Union{Node, Integer}, dest_node::Union{Node, Integer}) = Edge(nothing, relation, src_node, dest_node, Dict())


function _get_node_str(node::Node)
    return string(node)
end


function _get_node_str(node::Integer)
    return "()"
end


function string(edge::Edge)
    src_node_str = _get_node_str(edge.src_node)
    dest_node_str = _get_node_str(edge.dest_node)

    relation = ""
    props_str = ""
    
    if edge.relation != ""
        relation = ":" * edge.relation
    end

    if length(edge.properties) != 0
        props = ["$prop_name: " * prop_value_to_string(prop_value) for (prop_name, prop_value) in pairs(edge.properties)]
        props_str = "{" * join(props, ",") * "}"
    end
    "$src_node_str-[$relation $props_str]->$dest_node_str"
end


function isequal(x::Edge, y::Edge)
    if x.id !== nothing && y.id !== nothing && x.id != y.id
        return false
    end

    if x.relation != y.relation || x.src_node != y.src_node || x.dest_node != y.dest_node || x.properties != y.properties
        return false
    end

    return true
end


Base.:(==)(x::Edge, y::Edge) = isequal(x, y)
