
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
Node(id::Integer) = Node(id, nothing, "", Dict())


# TODO: should be moved to some common module
function prop_value_to_string(prop_value::Any) return "$prop_value" end
function prop_value_to_string(prop_value::String) return "\"$prop_value\"" end


function string(n::Node)
    alias = ""
    label = n.label
    props_str = ""

    if n.alias !== nothing
        alias = n.alias
    end

    if length(n.properties) != 0
        props = ["$prop_name: " * prop_value_to_string(prop_value) for (prop_name, prop_value) in pairs(n.properties)]
        props_str = "{" * join(props, ",") * "}"
    end
    "($alias:$label $props_str)"
end


function isequal(x::Node, y::Node)
    if x.id !== nothing && y.id !== nothing && x.id == y.id
        return true
    else
        if x.label == y.label && x.properties == y.properties
            return true
        end
    end
    return false
end


Base.:(==)(x::Node, y::Node) = isequal(x, y)
