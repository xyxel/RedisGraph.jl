
struct Node
    id::Union{Integer, Nothing}
    alias::Union{String, Nothing}
    label::String
    properties::Dict
end


Node(alias::String, label::String, properties::Dict) = Node(nothing, alias, label, properties)
Node(label::String, properties::Dict) = Node(nothing, nothing, label, properties)
Node(alias::String, label::String) = Node(nothing, alias, label, Dict())
Node(label::String) = Node(nothing, nothing, label, Dict())


function string(n::Node)
    alias = ""
    label = n.label
    props_str = ""

    if n.alias != nothing
        alias = n.alias
    end

    if length(n.properties) != 0
        props = ["$prop_name: $prop_value" for (prop_name, prop_value) in pairs(n.properties)]
        props_str = "{" * join(props, ",") * "}"
    end
    "($alias:$label $props_str)"
end
