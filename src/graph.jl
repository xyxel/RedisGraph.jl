using Redis: RedisConnectionBase


mutable struct Cache
    labels::Vector{String}
    relationshipTypes::Vector{String}
    propertyKeys::Vector{String}
    Cache() = new(Vector{String}(), Vector{String}(), Vector{String}())
end


struct Graph
    id::String
    redis_conn::RedisConnectionBase
    nodes::Dict
    edges::Vector{Edge}
    _cache::Cache
    Graph(id, redis_conn) = new(id, redis_conn, Dict(), Vector{Edge}(), Cache())
end


function addnode!(g::Graph, node::Node)
    g.nodes[node.alias] = node
end


function getnode(g::Graph, nodeid::Integer)
    res = query(g, "MATCH (node) WHERE ID(node) = $nodeid RETURN node")
    @assert !isempty(res) "There is no node with id=$nodeid"
    return res.results[1]
end


function call_procedure(g::Graph, procedure::AbstractString, args...; kwargs...)
    params = join(args, ",")
    query_str = "CALL $procedure($params)"

    yield_values = get(kwargs, :y, Vector())
    if length(yield_values) != 0
        values = join(yield_values, ",")
        query_str = query_str * " YIELD $values"
    end

    return query(g, query_str)
end


function lazy_update_cache!(cache::Cache, g::Graph, attr_name::String, required_idx::Int)
    if required_idx > length(getproperty(cache, Symbol(attr_name)))
        updated_value = call_procedure(g, "db.$attr_name").results
        setproperty!(cache, Symbol(attr_name), updated_value)
    end
end


function getlabel(g::Graph, idx::Int)
    required_idx = idx + 1
    lazy_update_cache!(g._cache, g, "labels", required_idx)
    return g._cache.labels[required_idx]
end


function getrelation(g::Graph, idx::Int)
    required_idx = idx + 1
    lazy_update_cache!(g._cache, g, "relationshipTypes", required_idx)
    return g._cache.relationshipTypes[required_idx]
end


function getprop(g::Graph, idx::Int)
    required_idx = idx + 1
    lazy_update_cache!(g._cache, g, "propertyKeys", required_idx)
    return g._cache.propertyKeys[required_idx]
end


function addedge!(g::Graph, edge::Edge)
    @assert haskey(g.nodes, edge.src_node.alias) && haskey(g.nodes, edge.dest_node.alias)
    push!(g.edges, edge)
end
