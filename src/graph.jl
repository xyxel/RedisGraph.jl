using Redis

mutable struct Graph
    id::String
    redis_conn::Redis.RedisConnectionBase
    nodes::Dict
    edges::Vector{Edge}
    _labels::Vector{String}
    _rel_types::Vector{String}
    _prop_names::Vector{String}
    Graph(id, redis_conn) = new(id, redis_conn, Dict(), Vector{Edge}(), Vector{String}(), Vector{String}(), Vector{String}())
end


function addnode!(g::Graph, node::Node)
    g.nodes[node.label] = node
end


function getnode(g::Graph, nodeid::Integer)
    res = RedisGraph.query(g, "MATCH (node) WHERE ID(node) = $nodeid RETURN node")
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


function getlabel(g::Graph, idx::Int)
    if idx >= length(g._labels)
        g._labels = call_procedure(g, "db.labels").results
    end
    return g._labels[idx+1]
end


function getrelation(g::Graph, idx::Int)
    if idx >= length(g._rel_types)
        g._rel_types = call_procedure(g, "db.relationshipTypes").results
    end
    return g._rel_types[idx+1]
end


function getprop(g::Graph, idx::Int)
    if idx >= length(g._prop_names)
        g._prop_names = call_procedure(g, "db.propertyKeys").results
    end
    return g._prop_names[idx+1]
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
    response = Redis.execute_command(g.redis_conn, Redis.flatten(["GRAPH.QUERY", g.id, q, "--compact"]))
    return QueryResult(g, response)
end


function flush!(g::Graph)
    commit(g)
    g.nodes = Dict()
    g.edges = Array{Edge, 1}()
end


function delete(g::Graph)
    Redis.execute_command(g.redis_conn, Redis.flatten(["GRAPH.DELETE", g.id]))
end


function merge(g::Graph, pattern::String)
    query_str = "MERGE $pattern"
    return query(g, query_str)
end


function convert(g::Graph, simple_edge::SimpleEdge)
    src_node = getnode(g, simple_edge.src_node_id)
    dest_node = getnode(g, simple_edge.dest_node_id)
    Edge(simple_edge.id, simple_edge.relation, src_node, dest_node, simple_edge.properties)
end
