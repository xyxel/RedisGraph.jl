using Redis: RedisConnectionBase, execute_command, flatten


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
    g.nodes[node.label] = node
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
    @assert haskey(g.nodes, edge.src_node.label) && haskey(g.nodes, edge.dest_node.label)
    push!(g.edges, edge)
end


function commit(g::Graph)
    if (length(g.nodes) == 0 && length(g.edges) == 0)
        return
    end

    items = vcat(string.(values(g.nodes)), string.(g.edges))

    query_str = "CREATE " * join(items, ",")
    return query(g, query_str)
end


function query(g::Graph, q::String)
    response = execute_command(g.redis_conn, flatten(["GRAPH.QUERY", g.id, q, "--compact"]))
    println(response)
    return QueryResult(g, response)
end


function flush!(g::Graph)
    commit(g)
    g.nodes = Dict()
    g.edges = Array{Edge, 1}()
end


function delete(g::Graph)
    execute_command(g.redis_conn, flatten(["GRAPH.DELETE", g.id]))
end


function merge(g::Graph, pattern::String)
    query_str = "MERGE $pattern"
    return query(g, query_str)
end
