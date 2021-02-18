struct Edge
    id::Union{Integer, Nothing}
    relation::String
    src_node::Union{Node, Integer}
    dest_node::Union{Node, Integer}
    properties::Dict
end

Edge(relation::String, src_node::Union{Node, Integer}, dest_node::Union{Node, Integer}, properties::Dict) = Edge(nothing, relation, src_node, dest_node, properties)
Edge(relation::String, src_node::Union{Node, Integer}, dest_node::Union{Node, Integer}) = Edge(nothing, relation, src_node, dest_node, Dict())


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
