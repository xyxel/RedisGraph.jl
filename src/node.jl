
using Random


struct Node
    id::Union{Integer, Nothing}
    alias::String
    labels::Vector{String}
    properties::Dict
end


function get_random_alias()
    return "alias_" * randstring()
end


Node(alias::String, labels::Vector{String}, properties::Dict) = Node(nothing, alias, labels, properties)
Node(labels::Vector{String}, properties::Dict) = Node(nothing, get_random_alias(), labels, properties)
Node(alias::String, labels::Vector{String}) = Node(nothing, alias, labels, Dict())
Node(labels::Vector{String}) = Node(nothing, get_random_alias(), labels, Dict())
Node(id::Integer) = Node(id, get_random_alias(), [], Dict())
Node(id::Integer, labels::Vector{String}, properties::Dict) = Node(id, get_random_alias(), labels, properties)


# TODO: should be moved to some common module
function prop_value_to_string(prop_value::Any) return "$prop_value" end
function prop_value_to_string(prop_value::String) return "\"$prop_value\"" end


function string(n::Node)
    alias = n.alias
    labels = join(n.labels, ":")
    props_str = ""

    if length(n.properties) != 0
        props = ["$prop_name: " * prop_value_to_string(prop_value) for (prop_name, prop_value) in pairs(n.properties)]
        props_str = "{" * join(props, ",") * "}"
    end
    "($alias:$labels $props_str)"
end


function isequal(x::Node, y::Node)
    if x.id !== nothing && y.id !== nothing && x.id != y.id
        return false
    end

    if x.labels != y.labels || x.properties != y.properties
        return false
    end

    return true
end


Base.:(==)(x::Node, y::Node) = isequal(x, y)
