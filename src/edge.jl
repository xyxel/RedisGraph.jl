struct Edge
    id::Union{Integer, Nothing}
    relation::String
    src_node::Node
    dest_node::Node
    properties::Dict
end

Edge(relation::String, src_node::Node, dest_node::Node, properties::Dict) = Edge(nothing, relation, src_node, dest_node, properties)
Edge(relation::String, src_node::Node, dest_node::Node) = Edge(nothing, relation, src_node, dest_node, Dict())

struct SimpleEdge
    id::Integer
    relation::String
    src_node_id::Integer
    dest_node_id::Integer
    properties::Dict
end


function string(edge::Edge)
    src_label = edge.src_node.label
    dst_label = edge.dest_node.label
    relation = ""
    relat_props = ""
    
    if edge.relation != ""
        relation = ":" * edge.relation
    end

    if length(edge.properties) != 0
        props = ["$prop_name: $prop_value" for (prop_name, prop_value) in pairs(edge.properties)]
        relat = "{" * join(props, ",") * "}"
    end

    "(:$src_label)-[$relation $relat_props]->(:$dst_label)"
end
